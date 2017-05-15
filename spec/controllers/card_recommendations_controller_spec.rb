require 'rails_helper'

RSpec.describe CardRecommendationsController do
  let(:account) { create_account(:eligible, :onboarded) }
  let(:person) { account.owner }

  before { sign_in account }

  describe 'GET #click' do
    let(:offer) { create_offer }
    let!(:rec) { create_card_recommendation(person: person, offer: offer) }

    let(:call) { get :click, params: { id: rec.id } }

    example 'when rec has not been clicked before' do
      raise unless rec.clicked_at.nil? # sanity check
      call
      expect(rec.reload.clicked_at).to be_within(5.seconds).of(Time.zone.now)

      expect(response).to redirect_to offer.link
    end

    example 'when rec has not been clicked before' do
      rec.update!(clicked_at: 10.days.ago)
      rec.reload # reload it now to avoid millisecond precision errors on CI
      call
      expect(rec.reload.clicked_at).to be_within(5.seconds).of(Time.zone.now)

      expect(response).to redirect_to offer.link
    end
  end
end
