class RecommendationNoteSerializer < ApplicationSerializer
  include ActionView::Helpers

  attributes :id, :content, :created_at

  def content
    auto_link(simple_format(object.content))
  end

  def created_at
    object.created_at.strftime("%F %r")
  end
end
