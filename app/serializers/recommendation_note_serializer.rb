class RecommendationNoteSerializer < ApplicationSerializer
  attributes :id, :content, :created_at

  def created_at
    object.created_at.strftime("%F %r")
  end
end
