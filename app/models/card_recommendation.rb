class CardRecommendation < ApplicationRecord
  belongs_to :card_application
  has_one :card, through: :card_application
  belongs_to :offer
  has_one :product, through: :offer
  belongs_to :person

  alias_attribute :recommended_at, :created_at

  # TODO this should be extracted to an op, but it can wait until we've made
  # the changes to the recrequest system because that will probably involve
  # changes to how recs are pulled
  def pull!
    self.pulled_at = Time.zone.now
    save
  end

  def status
    return 'pulled'   unless pulled_at.nil?
    return 'expired'  unless expired_at.nil?
    return 'declined' unless declined_at.nil?
    return 'applied'  if applied?
    'recommended'
  end

  def applied?
    !card_application.nil?
  end

  def applied_on
    card_application.applied_on if applied?
  end

  def applyable?
    status == 'recommended'
  end

  def declinable?
    status == 'recommended'
  end

  # Scopes

  scope :pulled,     -> { where.not(pulled_at: nil) }
  scope :unapplied,  -> { where(card_application_id: nil) }
  scope :unclicked,  -> { where(clicked_at: nil) }
  scope :undeclined, -> { where(declined_at: nil) }
  scope :unexpired,  -> { where(expired_at: nil) }
  scope :unpulled,   -> { where(pulled_at: nil) }
  scope :unseen,     -> { where(seen_at: nil) }

  # Recommendations which still require user action:
  scope :unresolved, -> { unpulled.unexpired.unapplied.undeclined }
end
