# See http://nithinbekal.com/posts/rails-presenters/
class ApplicationPresenter < SimpleDelegator

  def initialize(model, view)
    @model, @view = model, view
    super(@model)
  end

  def h
    @view
  end

end
