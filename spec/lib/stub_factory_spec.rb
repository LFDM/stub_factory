require 'stub_factory'

describe StubFactory do
  before :all do
    # the attr reader is set for convenience
    class A; attr_reader :test; end
  end

  describe "#new_stub" do
    it "returns a new instance" do
      A.new_stub.should be_an_instance_of A
    end

    it "takes variable hash and turns it to instance variables" do
      o = A.new_stub(vars: { test: 1 })
      o.test.should == 1
    end

    context "when a default template exists" do
      module StubFactory
        def stub_template_for_a
          { test: 1 }
        end
      end

      it "instantiates with default values of a template, deriving from class name" do
        A.new_stub.test.should == 1
      end

      it "overrides template when instantiated with vars hash" do
        o = A.new_stub(vars: { test: 2 })
        o.test.should_not == 1
        o.test.should     == 2
      end

      it "disables template set to nil" do
        o = A.new_stub(template: nil)
        o.test.should be_nil
      end
    end

    context "when a custom template exists" do
      module StubFactory
        def stub_template_for_esse
          { test: 12 }
        end
      end

      it "takes custom template as argument" do
        o = A.new_stub(template: :esse)
        o.test.should == 12
      end

      it "custom templates can be overridden" do
        o = A.new_stub(template: :esse, vars: { test: 1 })
        o.test.should == 1
      end
    end

    context "when methods need to be overridden" do
      class A
        def test_method
          12
        end
      end

      it "should leave methods intact without methods hash" do
        A.new_stub.test_method.should == 12
      end

      it "overrides methods with methods hash" do
        o = A.new_stub(methods: { test_method: 1 })
        o.test_method.should == 1
      end

      it "other instances' methods are not overridden by methods hash" do
        a = A.new_stub(methods: { test_method: 1 })
        b = A.new_stub(methods: { test_method: 2 })
        c = A.new_stub

        a.test_method.should == 1
        b.test_method.should == 2
        c.test_method.should == 12
      end
    end

    context "how default template lookup works" do
      it "takes class name of self and returns an underscored symobl, namespaces are marked with double underscore" do
        module TestNamespace
          class TestClass; end
        end

        class_name = TestNamespace::TestClass.new.class.name
        StubFactory.to_underscored_symbol(class_name).should == :test_namespace__test_class
      end
    end
  end
end
