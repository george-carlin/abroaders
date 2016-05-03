# See http://nithinbekal.com/posts/rails-presenters/
class ApplicationPresenter < SimpleDelegator

  def initialize(model, view)
    @model, @view = model, view
    super(@model)
  end

  def h
    @view
  end

  def t(*args)
    I18n.t(*args)
  end

end
