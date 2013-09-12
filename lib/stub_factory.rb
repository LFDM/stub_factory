require_relative 'stubs'

module StubFactory
  def new_stub(vars: {}, methods: {}, template: self.name.underscore)
    obj = allocate

    if self.methods.include?(template_for(template))
      vars = send(template_for(template)).merge!(vars)
    end

    set_instance_variables(obj, vars)
    override_methods(obj, methods)
    obj
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
