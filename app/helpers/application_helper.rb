module ApplicationHelper
  include BootstrapOverrides::Overrides

  # See http://nithinbekal.com/posts/rails-presenters/
  def present(model, presenter_class=nil)
    presenter = get_presenter(model, presenter_class)
    yield(presenter)
  end

  def present_each(collection, presenter_class=nil, &block)
    collection.each do |model|
      presenter = get_presenter(model, presenter_class)
      yield(presenter)
    end
  end

  def sidebar?
    # Urgh... this probably isn't the best way to handle sidebar-less layouts
    # but it'll do for now.
    !content_for?(:no_sidebar)
  end

  private

  def get_presenter(model, klass=nil)
    klass ||= "#{model.class}Presenter".constantize
    klass.new(model, self)
  end

end
