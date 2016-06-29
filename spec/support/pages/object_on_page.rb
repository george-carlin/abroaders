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
    define_method "#{name}_check_box" do
      find("##{selector}")
    end

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

  def self.radio(name, html_name, values)
    define_method "#{name}_radio" do
      find("##{selector}")
    end

    values.each do |value|
      define_method "has_#{name}_#{value}_radio?" do
        has_field?("#{html_name}_#{value}")
      end

      define_method "has_no_#{name}_#{value}_radio?" do
        has_no_field?("#{html_name}_#{value}")
      end

      define_method "choose_#{name}_#{value}" do
        choose "#{html_name}_#{value}"
      end
    end

    define_method "has_#{name}_radios?" do
      values.all? do |value|
        send("has_#{name}_#{value}_radio?")
      end
    end

    define_method "has_no_#{name}_radios?" do
      values.all? do |value|
        send("has_no_#{name}_#{value}_radio?")
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

  def within(&block)
    super(dom_selector, &block)
  end
  alias_method :within_self, :within

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
