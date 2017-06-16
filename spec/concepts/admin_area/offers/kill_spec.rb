require 'rails_helper'

RSpec.describe AdminArea::Offers::Kill do
  let(:admin) { create_admin }

  let(:op) { described_class }

  let(:offer) { create_offer }

  example 'killing an offer' do
    result = op.({ id: offer.id }, 'admin' => admin)
    expect(result.success?).to be true

    updated_offer = result['model']
    expect(updated_offer).to eq offer
    expect(updated_offer.killed_at).to be_within(5.seconds).of Time.zone.now
  end

  example 'killing an offer and replacing it in recs' do
    rec = create_rec(offer: offer)
    replacement = create_offer
    result = op.({ id: offer.id, replacement_id: replacement.id }, 'admin' => admin)
    expect(result.success?).to be true

    updated_offer = result['model']
    expect(updated_offer).to eq offer
    expect(updated_offer.killed_at).to be_within(5.seconds).of Time.zone.now

    expect(rec.reload.offer).to eq replacement
  end

  example 'failure - offer already dead' do
    op.({ id: offer.id }, 'admin' => admin) # kill it
    result = op.({ id: offer.id }, 'admin' => admin) # try to kill it again
    expect(result.success?).to be false
    expect(result['error']).to eq 'Offer already killed'
  end
end
