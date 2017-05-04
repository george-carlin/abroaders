require 'rails_helper'

RSpec.describe AdminArea::Offers::Verify do
  let(:admin) { create_admin }

  let(:op) { described_class }

  let(:offer) { create_offer }

  example 'verifying an offer' do
    result = op.({ id: offer.id }, 'current_admin' => admin)
    expect(result.success?).to be true

    updated_offer = result['model']
    expect(updated_offer).to eq offer
    expect(updated_offer.last_reviewed_at).to be_within(2.seconds).of Time.zone.now
  end

  example 'failure - offer dead' do
    kill_offer(offer)
    result = op.({ id: offer.id }, 'current_admin' => admin) # try to verify
    expect(result.success?).to be false
    expect(result['error']).to eq "Can't verify a dead offer"
  end

  # unknown offers are an implementation detail; admins shouldn't be able to
  # see them in the first place to verify them
  example 'failure - offer has unknown condition' do
    offer = create(:card_product).unknown_offer
    result = op.(id: offer.id)
    expect(result['error']).to eq 'Unknown offer'
  end
end
