require 'rails_helper'

RSpec.describe CardRecommendation do
  example '#pull!' do
    rec = run!(
      AdminArea::CardRecommendations::Operation::Create,
      card_recommendation: { offer_id: create_offer.id }, person_id: create(:person).id,
    )['model']

    rec.pull!
    expect(rec.reload.pulled_at).to be_within(5.seconds).of(Time.now)
  end
end
