module Termtter
  class RubytterProxy
    include Hookable

    def initialize(*args)
      @rubytter = Rubytter.new(*args)
    end

    def method_missing(method, *args, &block)
      if @rubytter.methods.include?(method.to_s)
        result = nil
        begin
          modified_args = args
          hooks = self.class.get_hooks("pre_#{method}")
          hooks.each do |hook|
            modified_args = hook.call(*modified_args)
          end

          result = @rubytter.__send__(method, *modified_args)

          self.class.call_hooks("post_#{method}", *args)
        rescue HookCanceled
        end
        result
      else
        super
      end
    end
  end
end
