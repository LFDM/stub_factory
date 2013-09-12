require 'stub_factory/version'

module StubFactory
  def new_stub(vars: {}, methods: {}, template: StubFactory.to_underscored_symbol(self.name))
    obj = allocate

    if respond_to?(template_for(template))
      vars = send(template_for(template)).merge!(vars)
    end

    set_instance_variables(obj, vars)
    override_methods(obj, methods)
    obj
  end

  def self.to_underscored_symbol(class_name)
    # Namespace::TestClass to :namespace__test_class
    res = class_name.to_s.dup
    res.gsub!(/([a-z])([A-Z])/) { "#{$1}_#{$2}" }
    res.gsub!(/::/, "__")
    res.downcase.to_sym
  end

  private

  def template_for(template)
    "stub_template_for_#{template}".to_sym
  end

  def set_instance_variables(obj, vars)
    vars.each do |var, val|
      obj.instance_variable_set("@#{var}", val)
    end
  end

  def override_methods(obj, methods)
    methods.each do |meth, val|
      obj.send(:define_singleton_method, meth) do
        val
      end
    end
  end
end

class Class; include StubFactory; end
