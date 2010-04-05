# -*- coding: utf-8 -*-

config.plugins.tinyurl.set_default(:shorturl_makers, [
    { :host => "api.bit.ly",
      :format => '/shorten?version=2.0.1&longUrl=%s&login=termtter&apiKey=R_e7f22d523a803dbff7f67de18c109856' },
    { :host => "is.gd", :format => '/api.php?longurl=%s' },
    { :host => "tinyurl.com", :format => '/api-create.php?url=%s' },
  ])
config.plugins.tinyurl.set_default(:tinyurl_hook_commands, [:update, :reply, :retweet])
config.plugins.tinyurl.set_default(:uri_regexp, URI.regexp(%w(http https ftp)))

module Termtter::Client
  register_hook(
    :name => :tinyurl,
    :points => config.plugins.tinyurl.tinyurl_hook_commands.map {|cmd|
      "modify_arg_for_#{cmd.to_s}".to_sym
    },
    :exec_proc => lambda {|cmd, arg|
      arg.gsub(/#{config.plugins.tinyurl.uri_regexp}\S*/) do |url|
        result = nil
        config.plugins.tinyurl.shorturl_makers.each do |site|
          result = shorten_url(url, site[:host], site[:format])
          break if result
        end
        result or url
      end
    }
  )

  # returns nil if not shorten
  def self.shorten_url(url, host, format)
    url_enc = URI.escape(url, /[^a-zA-Z0-9.:]/)
    res = Termtter::HTTPpool.start(host) do |h|
      h.get(format % url_enc)
    end
    if res.code == '200'
      result = res.body
      if /"shortUrl": "(http.*)"/ =~ result
        result = $1
      elsif /"statusCode": "ERROR"/ =~ result
        return nil
      end
      result
    else
      nil
    end
  end

end

# tinyuri.rb
# make URLs in your update to convert tinyurl.com/XXXXXXX.
