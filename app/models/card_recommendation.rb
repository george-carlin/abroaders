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
end
