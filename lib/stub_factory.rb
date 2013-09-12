require 'stub_factory/version'
require 'stub_factory/exceptions'

module StubFactory
  @stub_factory_paths = %w{ spec/factories }
  @stub_factory_helpers_paths = %w{ spec/support/helpers }
  @templates = {}
  @helpers   = []

  class << self
    def to_underscored_symbol(class_name)
      # Namespace::TestClass to :namespace__test_class
      res = class_name.to_s.dup
      res.gsub!(/([a-z])([A-Z])/) { "#{$1}_#{$2}" }
      res.gsub!(/::/, "__")
      res.downcase.to_sym
    end

    def define_template(template_name)
      tn = template_name.to_sym
      raise TemplateError, "Template already defined" if template_defined?(tn)
      raise TemplateError, "Templates need to be defined with a block" unless block_given?
      values = yield
      raise TemplateError, "Block must contain a Hash" unless values.kind_of?(Hash)
      @templates[tn] = values
    end

    def template_defined?(template)
      return unless template
      @templates.has_key?(template.to_sym)
    end

    def template_for(template)
      @templates[template.to_sym]
    end

    def define_helper(helper, klass)
      raise HelperError, "A helper for #{helper} has already been defined" if helper_defined?(helper)
      @helpers << helper.to_sym

      Object.class_eval <<-STR
        def stub_#{helper}(vars: {}, methods: {})
          #{klass}.new_stub(vars: vars, methods: methods, template: :#{helper})
        end
      STR
    end

    def helper_defined?(helper)
      @helpers.include?(helper.to_sym)
    end

    def add_factory_path(path)
      @stub_factory_paths << path
    end

    def add_helpers_path(path)
      @stub_factory_helpers_paths << path
    end

    def recursive_require(rel_paths)
      rel_paths.each do |rel_path|
        require_path(rel_path)
      end
    end

    def require_path(rel_path)
      path = File.expand_path(rel_path)

      if File.exists?(path)
        require "#{path}" if File.file?(path)
        Dir["#{path}/*"].each { |file| require_path(file) }
      end
    end
  end

  recursive_require(@stub_factory_paths)
  recursive_require(@stub_factory_helpers_paths)

  def new_stub(vars: {}, methods: {}, template: StubFactory.to_underscored_symbol(self.name))
    obj = allocate

    if StubFactory.template_defined?(template)
      vars = StubFactory.template_for(template).merge(vars)
    end

    set_instance_variables(obj, vars)
    override_methods(obj, methods)
    obj
  end

  private

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
