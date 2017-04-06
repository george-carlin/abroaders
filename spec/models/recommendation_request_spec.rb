require 'rails_helper'

RSpec.describe RecommendationRequest do
  let(:account) { create(:account, :onboarded, :eligible) }

  example '#confirm!' do
    run!(described_class::Create, { person_type: 'owner' }, 'account' => account)

    req = account.owner.unconfirmed_recommendation_request

    expect(req).to be_unconfirmed
    req.confirm!
    expect(req.reload).to be_confirmed
  end
end
