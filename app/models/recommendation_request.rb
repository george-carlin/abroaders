class RecommendationRequest < ApplicationRecord
  belongs_to :person

  def status
    return 'resolved' if resolved?
    return 'confirmed' if confirmed?
    'unconfirmed'
  end

  def confirm!
    update!(confirmed_at: Time.zone.now)
  end

  def confirmed?
    !confirmed_at.nil?
  end

  def unconfirmed?
    confirmed_at.nil?
  end

  def unresolved?
    resolved_at.nil?
  end

  def resolved?
    !resolved_at.nil?
  end

  scope :unresolved, -> { where(resolved_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }
end
