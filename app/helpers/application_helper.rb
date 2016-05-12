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

  def present_div(model, presenter_class_or_html_opts=nil, html_opts={})
    if presenter_class_or_html_opts.is_a?(Hash)
      html_opts       = presenter_class_or_html_opts
      presenter_class = nil
    else
      presenter_class = presenter_class_or_html_opts
    end

    present(model, presenter_class) do |presenter|
      div_for presenter, html_opts do
        yield(presenter)
      end
    end
  end

  def sidebar?
    # Urgh... this probably isn't the best way to handle sidebar-less layouts
    # but it'll do for now.
    !content_for?(:no_sidebar)
  end

  private

  def get_presenter(model, klass=nil)
    if model.is_a?(ApplicationPresenter)
      model
    else
      klass ||= "#{model.class}Presenter".constantize
      klass.new(model, self)
    end
  end

end
