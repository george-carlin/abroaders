class ObjectOnPage < Struct.new(:spec_context)
  include Capybara::DSL

  def self.t(*args)
    I18n.t(*args)
  end

  def present?
    has_selector?(dom_selector)
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

end
