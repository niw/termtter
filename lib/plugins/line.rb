Termtter::Client.register_command(
  :name => :line,
  :help => 'Draws a line without any side effect on Twitter.',
  #:aliases => [:l],
  :exec_proc => lambda {|arg|
    return if RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|bccwin/
    window_width = (ENV['COLUMNS'] || `stty size`[/\d+\s+(\d+)/, 1]).to_i
    text = '<dark>' + (' ' * window_width) + '</dark>'
    puts TermColor.parse(text)
  }
)
