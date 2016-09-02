# See http://nithinbekal.com/posts/rails-presenters/
class ApplicationPresenter < SimpleDelegator
  include I18nWithErrorRaising

  attr_reader :model

  def initialize(model, view)
    @model, @view = model, view
    super(@model)
  end

  # SimpleDelegator doesn't forward private methods, but content_tag_for
  # relies on the private method to_ary. Make to_ary public to prevent
  # content_tag_for from displaying a warning:
  def to_ary
    model.send(:to_ary)
  end

  private

  def h
    view
  end

  def raw(*args)
    h.raw(*args)
  end

  attr_reader :view

end
