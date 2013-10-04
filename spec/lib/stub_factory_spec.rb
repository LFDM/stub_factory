require 'spec_helper'
require 'stub_factory'

describe StubFactory do
  before :all do
    # the attr reader is set for convenience
    class A; attr_reader :test; end
  end

  describe ".define_template" do
    after :each do
      # delete the just created template because it would persist
      StubFactory.instance_variable_get(:@templates).delete(:test)
    end

    it "defines a template" do
      StubFactory.define_template(:test) { {} }
      StubFactory.template_defined?(:test).should be_true
    end

    it "templates can only be defined once" do
      StubFactory.define_template(:test) { {} }
      expect { StubFactory.define_template(:test) { {} } }.to raise_error(StubFactory::TemplateError)
    end

    it "templates need to be defined with a block" do
      expect { StubFactory.define_template(:test).to raise_error(StubFactory::TemplateError) }
    end
  end

  describe ".define_helper" do
    it 'defines helper methods - shortcuts #stub_#{helper} that use a specific template (first argument) on a new stub of a given class (second argument)' do
      StubFactory.define_template(:helper) { { test: 13 } }
      StubFactory.define_helper(:helper, :A)

      stub_helper.should be_an_instance_of A
      stub_helper.test.should == 13
    end

    it "helpers cannot be defined twice" do
      StubFactory.define_helper(:helper2, :A)
      expect { StubFactory.define_helper(:helper2, :A) }.to raise_error(StubFactory::HelperError)
    end

    it "helpers can be defined in files called stub_***.rb - default path is spec/support/helpers" do
      # required_helper is defined in #spec/support/stub_helper_test.rb
      stub_required_helper.should be_an_instance_of A
    end

    it "to allow other files in this folder wrongly named files are not consumed" do
      # wrong_helper is defined in #spec/support/wrong_helper_test.rb
      expect { stub_wrong_helper }.to raise_error NameError
    end
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
      StubFactory.define_template(:a) do
        { test: 5 }
      end

      it "instantiates with default values of a template, deriving from class name" do
        A.new_stub.test.should == 5
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

      it "templates can be defined in files called template_**.rb - their default path is spec/factories" do
        # required_template is defined in #spec/factories/template_test.rb
        A.new_stub(template: :required_template).test.should == 11
      end

      it "to allow other files in this folder wrongly named files are not consumed" do
        # wrong_template is defined in #spec/factories/wrong_test.rb
        # with the variable test == 11
        A.new_stub(template: :wrong_template).test.should be_nil
      end
    end

    context "when a custom template exists" do
      StubFactory.define_template(:esse) do
        { test: 12 }
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

      it "leaves methods intact when not overwritten by methods hash" do
        A.new_stub.test_method.should == 12
      end

      it "overrides methods with methods hash" do
        o = A.new_stub(methods: { test_method: 1 })
        o.test_method.should == 1
      end

      it "other instances' methods are not overwritten by methods hash - it happens on a singleton level" do
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
