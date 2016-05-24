class ModelOnPage < Struct.new(:model, :spec_context)
  include ActionView::RecordIdentifier
  include Capybara::DSL

  def self.t(*args)
    I18n.t(*args)
  end

  def self.button(name, text)
    define_method "has_#{name}_button?" do
      has_button?(text)
    end
    alias_method "has_#{name}_btn?", "has_#{name}_button?"

    define_method "has_no_#{name}_button?" do
      has_no_button?(text)
    end
    alias_method "has_no_#{name}_btn?", "has_no_#{name}_button?"

    define_method "click_#{name}_button" do
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

  %i[button content field].each do |element|
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

  def present?
    has_selector?(dom_selector)
  end

  private

  def within_self(&block)
    within(dom_selector, &block)
  end

  def dom_id
    super(model)
  end

  def dom_selector
    "#" << dom_id
  end

  def id
    model.id
  end

  def method_missing(meth, *args, &block)
    if spec_context.respond_to?(meth)
      spec_context.send(meth, *args, &block)
    else
      super
    end
  end

end
