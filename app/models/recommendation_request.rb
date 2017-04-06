class RecommendationRequest < ApplicationRecord
  belongs_to :person

  def status
    resolved? ? 'resolved' : 'unresolved'
  end

  def unresolved?
    resolved_at.nil?
  end

  def resolved?
    !unresolved?
  end

  scope :unresolved, -> { where(resolved_at: nil) }
  scope :resolved, -> { where.not(resolved_at: nil) }
end
