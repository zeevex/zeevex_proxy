module ZeevexProxy
  if defined? ::BasicObject
    # A class with no predefined methods that behaves similarly to Builder's
    # BlankSlate. Used for proxy classes.
    class BasicObject < ::BasicObject
      undef_method :==
      undef_method :equal?

      # Let ActiveSupport::BasicObject at least raise exceptions.
      def raise(*args)
        ::Object.send(:raise, *args)
      end
    end
  else
    class BasicObject
      KEEP_METHODS = %w"__id__ __send__ method_missing __getobj__"

      def self.remove_methods!
        m = (instance_methods) - KEEP_METHODS
        m.each{|m| undef_method(m)}
      end

      def initialize(*args)
        BasicObject.remove_methods!
      end

      BasicObject.remove_methods!
    end
  end

  class Base < BasicObject
    def initialize(target, options = {}, &block)
      super()
      @obj = @__proxy_object__ = target
      if block
        eigenclass = class << self; self; end
        eigenclass.__send__(:define_method, :method_missing, &block)
      end
    end

    def __getobj__
      @__proxy_object__
    end

    def method_missing(name, *args, &block)
      __getobj__.__send__(name, *args, &block)
    end

  end
end
