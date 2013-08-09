module ZeevexProxy
  if Object.const_defined?("BasicObject")
    # A class with no predefined methods that behaves similarly to Builder's
    # BlankSlate. Used for proxy classes.
    class BasicObject < ::BasicObject
      undef_method :==
      undef_method :equal?

      # Let ActiveSupport::BasicObject at least raise exceptions.
      def raise(*args)
        ::Object.send(:raise, *args)
      end
      
      def initialize(*args); end
    end
  else
    puts "Defining our own BasicObject"
    class BasicObject
      KEEP_METHODS = %w"__id__ __send__ method_missing __getobj__".map(&:to_sym)

      def self.remove_methods!
        m = (instance_methods.map(&:to_sym)) - KEEP_METHODS
        m.each{|m| undef_method(m)}
      end

      def self.inherited(subclass)
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

    def __substitute_self__(candidate, pself)
      candidate.__id__ == pself.__id__ ? self : candidate
    end

    # if chainable method or returns "self" for some other reason,
    # return this proxy instead
    def method_missing(name, *args, &block)
      obj = __getobj__
      __substitute_self__(obj.__send__(name, *args, &block), obj)
    end

    def object_id
      __getobj__.object_id
    end

  end
end
