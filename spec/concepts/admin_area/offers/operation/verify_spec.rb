require 'rails_helper'

RSpec.describe AdminArea::Offers::Operation::Verify do
  let(:op) { described_class }

  let(:offer) { create_offer }

  example 'verifying an offer' do
    result = op.(id: offer.id)
    expect(result.success?).to be true

    updated_offer = result['model']
    expect(updated_offer).to eq offer
    expect(updated_offer.last_reviewed_at).to be_within(2.seconds).of Time.zone.now
  end

  example 'failure - offer dead' do
    AdminArea::Offers::Operation::Kill.(id: offer.id) # kill it
    result = op.(id: offer.id) # try to verify
    expect(result.success?).to be false
    expect(result['error']).to eq "Can't verify a dead offer"
  end
end
