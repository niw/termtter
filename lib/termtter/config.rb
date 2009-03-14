# -*- coding: utf-8 -*-

def config; Termtter::Config.instance end

def configatron
  # remove this method until Termtter-1.2.0
  warn "configatron method will be removed. Use config instead. (#{caller.first})"
  Termtter::Config.instance
end

module Termtter
  module Config
    class Storage
      def initialize(name, value = nil, parent = nil)
        @_name = (parent ? "#{parent}." : '') + name
        @_value = value
      end

      def method_missing(sym, *args)
        method(sym).call
      rescue
        name = sym.to_s.gsub(/(=)\z/, '')
        value = $1 ? args.shift : nil
        child = self.class.new(name, value, @_name)
        metaclass.__send__(:define_method, name) { value ? value : child }
        child
      end

      def set_default(name, value)
        method(name)
      rescue
        key, *storages = name.to_s.split('.').reverse
        unless storages.empty?
          eval("self.#{storages.reverse.join}").__send__("#{key}=", value)
        else
          self.__send__("#{key}=", value)
        end
      ensure
        nil
      end

      def inspect; "#{@_name}" end
      def nil?; @_value.nil? end

      def metaclass; class << self; self end end
      private :metaclass
    end

    class << self
      _instance = Storage.new('config')
      define_method(:instance) { _instance }
    end
  end
end
