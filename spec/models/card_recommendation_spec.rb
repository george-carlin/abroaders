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

  describe '#status' do
    # possible values: [recommended, declined, applied, pulled, expired]
    let(:attrs) { {} }
    let(:time) { Time.now }

    subject { described_class.new(attrs).status }

    context 'when pulled_at is present' do
      before { attrs[:pulled_at] = time }
      it { is_expected.to eq 'pulled' }
    end

    context 'when expired_at is present' do
      before { attrs[:expired_at] = time }
      it { is_expected.to eq 'expired' }
    end

    context 'when application ID is present' do
      before { attrs[:card_application_id] = 1 }
      it { is_expected.to eq 'applied' }
    end

    context 'when rec is not declined, applied, pulled, or expired' do
      it { is_expected.to eq 'recommended' }
    end
  end
end
