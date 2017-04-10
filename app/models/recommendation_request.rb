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

  # @return [Time] the new resolved_at timestamp
  # @raise [RecommendationRequest::AlreadyResolvedError] if already resolved
  def resolve!
    raise AlreadyResolvedError if resolved?
    update!(resolved_at: Time.zone.now)
    resolved_at
  end

  scope :unresolved, -> { where(resolved_at: nil) }
  scope :resolved, -> { where.not(resolved_at: nil) }

  class AlreadyResolvedError < StandardError
    def initialize
      super('request already resolved')
    end
  end
end
