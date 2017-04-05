class RecommendationRequest < ApplicationRecord
  belongs_to :person

  Status = Types::Strict::String.enum('unconfirmed', 'confirmed', 'resolved')

  # Forget validations; don't allow an invalid attribute to be set in the first
  # place:
  def status=(new_status)
    super(Status.(new_status))
  end

  def unresolved?
    status != 'resolved'
  end

  scope :unresolved, -> { where.not(status: 'resolved') }
  scope :unconfirmed, -> { where(status: 'unconfirmed') }
end
