module ApplicationHelper
  include BootstrapOverrides::Overrides

  # See http://nithinbekal.com/posts/rails-presenters/
  def present(model, presenter_class = nil)
    presenter = get_presenter(model, presenter_class)
    block_given? ? yield(presenter) : presenter
  end

  def present_each(collection, presenter_class = nil)
    collection.each do |model|
      presenter = get_presenter(model, presenter_class)
      yield(presenter)
    end
  end

  def present_div(model, presenter_class_or_html_opts = nil, html_opts = {})
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

  def serialize(model, serializer_class = nil)
    serializer_class ||= "#{model.to_model.class}Serializer".constantize
    serializer_class.new(model).to_json
  end

  def serialize_collection(models, serializer_class = nil)
    serializer_class ||= "#{models.first.class.name}Serializer".constantize
    models.map{ |model| serializer_class.new(model) }.to_json
  end

  private

  def get_presenter(model, klass = nil)
    if model.is_a?(ApplicationPresenter)
      model
    else
      klass ||= "#{model.class}Presenter".constantize
      klass.new(model, self)
    end
  end
end
