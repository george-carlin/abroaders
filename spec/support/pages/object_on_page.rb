class ObjectOnPage < Struct.new(:spec_context)
  include Capybara::DSL

  def self.t(*args)
    I18n.t(*args)
  end

  def self.button(name, text)
    define_method "has_#{name}_button?" do
      text = instance_eval(&text) if text.is_a?(Proc)
      has_button?(text)
    end
    alias_method "has_#{name}_btn?", "has_#{name}_button?"

    define_method "has_no_#{name}_button?" do
      text = instance_eval(&text) if text.is_a?(Proc)
      has_no_button?(text)
    end
    alias_method "has_no_#{name}_btn?", "has_no_#{name}_button?"

    define_method "click_#{name}_button" do
      text = instance_eval(&text) if text.is_a?(Proc)
      click_button(text)
    end
    alias_method "click_#{name}_btn", "click_#{name}_button"
  end

  def self.field(method, name)
    define_method method do
      if name.is_a?(Proc)
        instance_eval(&name)
      else
        name
      end
    end

    define_method "fill_in_#{method}" do |opts={}|
      field = name.is_a?(Proc) ? instance_eval(&name) : name
      fill_in field, opts
    end

    define_method "has_#{method}_field?" do
      field = name.is_a?(Proc) ? instance_eval(&name) : name
      has_field?(field)
    end

    define_method "has_no_#{method}_field?" do
      field = name.is_a?(Proc) ? instance_eval(&name) : name
      has_no_field?(field)
    end
  end

  def self.check_box(name, selector)
    define_method "has_#{name}_check_box?" do
      has_field?(selector.is_a?(Proc) ? instance_eval(&selector) : selector)
    end

    define_method "has_no_#{name}_check_box?" do
      has_no_field?(selector.is_a?(Proc) ? instance_eval(&selector) : selector)
    end

    define_method "check_#{name}" do
      within_self do
        check selector.is_a?(Proc) ? instance_eval(&selector) : selector
      end
    end

    define_method "uncheck_#{name}" do
      within_self do
        uncheck selector.is_a?(Proc) ? instance_eval(&selector) : selector
      end
    end
  end

  def self.section(name, selector)
    define_method "has_#{name}?" do
      has_selector?(selector)
    end

    define_method "has_no_#{name}?" do
      has_no_selector?(selector)
    end
  end

  def present?
    spec_context.has_selector?(dom_selector)
  end

  def absent?
    spec_context.has_no_selector?(dom_selector)
  end

  def dom_selector
    raise NotImplementedError
  end

  def method_missing(meth, *args, &block)
    if spec_context.respond_to?(meth)
      spec_context.send(meth, *args, &block)
    else
      super
    end
  end

  def within_self(&block)
    within(dom_selector, &block)
  end

  %i[button content field selector].each do |element|
    ["has_#{element}?", "has_no_#{element}?"].each do |meth|
      define_method meth do |*args|
        within_self { super(*args) }
      end
    end
  end

  %i[button link].each do |element|
    define_method "click_#{element}" do |*args|
      within_self { super(*args) }
    end
  end

end
