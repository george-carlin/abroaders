require 'rails_helper'

RSpec.describe AdminArea::Offers::Operation::Kill do
  let(:op) { described_class }

  let(:offer) { create(:offer, :live) }

  example 'killing an offer' do
    result = op.(id: offer.id)
    expect(result.success?).to be true

    updated_offer = result['model']
    expect(updated_offer).to eq offer
    expect(updated_offer.killed_at).to be_within(5.seconds).of Time.zone.now
  end

  example 'failure - offer already dead' do
    op.(id: offer.id) # kill it
    result = op.(id: offer.id) # try to kill it again
    expect(result.success?).to be false
    expect(result['error']).to eq 'Offer already killed'
  end
end
