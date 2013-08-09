# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.

describe ZeevexProxy::Base do
  class Responder
    def responder_method
      "itsa me"
    end

    def called_with_block?
      block_given?
    end

    def block_call
      yield
    end

    # expected to be defined on Object
    def to_enum
      "this is not an enum"
    end
  end

  before(:each) do
    Object.class_eval do
      def responder_method
        "shouldn't see this one"
      end
    end

    class ProxyClass < ZeevexProxy::Base; end
  end

  after(:each) do
    Object.send :undef_method, :responder_method
  end

  let :object do
    Responder.new
  end
  
  let :proxy do
    ProxyClass.new object
  end

  context "hygiene" do
    it "should not have instance methods previously defined on Object" do
      ProxyClass.instance_methods.map(&:to_sym).should_not include(:responder_method)
    end
  end

  context "instance identity" do
    subject { proxy }
    it "identifies as an instance of its proxy target" do
      proxy.should be_instance_of(Responder)
    end
    it "returns Responder as the class" do
      proxy.class.should == Responder
    end
    it "responds_to a defined method on Responder" do
      proxy.should respond_to(:responder_method)
    end
    it "has the same object_id as the proxy target" do
      proxy.object_id.should == object.object_id
    end
    it "returns target to __getobj__" do
      proxy.__getobj__.should == object
    end
    it "should return methods" do
      proxy.method(:responder_method).should == object.method(:responder_method)
    end
  end

  context "proxying to object" do
    it "should receive stub messages with arguments called on the proxy" do
      object.should_receive(:foo).with(5).and_return(100)
      proxy.foo(5).should == 100
    end

    it "should receive messages called with :send on the proxy" do
      object.should_receive(:foo).and_return(200)
      proxy.send(:foo).should == 200
    end

    it "should call the target's method for a method defined in Object" do
      proxy.to_enum.should == "this is not an enum"
    end

    # the Object methods are undef'd at the time BasicObject is defined; anything loaded
    # after that may add methods to Object which will not be passed to method_missing, and
    # this not proxied to the target.
    it "should call the target's method for a method defined in Object *after* proxy creation" do
      proxy.responder_method.should == "itsa me"
    end

    it "should pass along blocks to proxy methods" do
      proxy.called_with_block? { nil }.should == true
    end

    it "should return its own ptr if proxied method returns self" do
      object.should_receive(:chainable).and_return(object)
      proxy.chainable.__id__.should == proxy.__id__
    end
  end

  context "method_missing provided as block" do
    subject {
      ZeevexProxy::Base.new({}) do |meth, *args, &block|
        res = [meth, *args]
        if block
          yield res
        else
          res
        end
      end
    }
    it "should receive stub messages with arguments called on the proxy" do
      subject.foo(5).should == [:foo, 5]
    end

    it "should receive messages called with :send on the proxy" do
      subject.__send__(:foo).should == [:foo]
    end

    it "should receive messages called with :send on the proxy" do
      subject.send(:foo).should == [:send, :foo]
    end
  end

end
