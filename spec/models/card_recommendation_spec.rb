require 'rails_helper'

RSpec.describe CardRecommendation do
  example '#pull!' do
    rec = create_card_recommendation
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
      before { attrs[:card_application] = CardApplication.new }
      it { is_expected.to eq 'applied' }
    end

    context 'when rec is not declined, applied, pulled, or expired' do
      it { is_expected.to eq 'recommended' }
    end
  end

  example "#applyable?" do
    rec = described_class.new
    expect(rec.applyable?).to be true

    rec.pulled_at = Time.now
    expect(rec.applyable?).to be false
    rec.pulled_at = nil

    rec.expired_at = Time.now
    expect(rec.applyable?).to be false
    rec.expired_at = nil

    rec.declined_at = Time.now
    expect(rec.applyable?).to be false
    rec.declined_at = nil

    rec.card_application = CardApplication.new
    expect(rec.applyable?).to be false
  end

  example "#declinable?" do
    rec = described_class.new
    expect(rec.declinable?).to be true

    rec.pulled_at = Time.now
    expect(rec.declinable?).to be false
    rec.pulled_at = nil

    rec.expired_at = Time.now
    expect(rec.declinable?).to be false
    rec.expired_at = nil

    rec.declined_at = Time.now
    expect(rec.declinable?).to be false
    rec.declined_at = nil

    rec.card_application = CardApplication.new
    expect(rec.declinable?).to be false
  end

  example '#applied_on' do
    rec = CardRecommendation.new
    expect(rec.applied_on).to be_nil
    app = CardApplication.new(applied_on: Time.now)
    rec.card_application = app
    expect(rec.applied_on).to eq app.applied_on

    # CardApplications shouldn't exist with no applied_on date, so this is an error condition:
    rec.card_application = CardApplication.new
    expect { rec.applied_on }.to raise_error RuntimeError
  end

  example ".unresolved" do
    product = create(:card_product)
    offer   = create_offer(product: product)
    person  = create(:account, :onboarded).owner

    # resolved:
    create_card_recommendation(:pulled,   offer_id: offer.id, person_id: person.id)
    create_card_recommendation(:expired,  offer_id: offer.id, person_id: person.id)

    declined = create_card_recommendation(:declined, offer_id: offer.id, person_id: person.id)
    run!(
      CardRecommendation::Operation::Decline,
      { id: declined.id, card: { decline_reason: 'x' } },
      'account' => person.account,
    )
    applied = create_card_recommendation(offer_id: offer.id, person_id: person.id)
    run!(
      CardRecommendation::Operation::UpdateStatus::Applied,
      { id: applied.id },
      'account' => person.account,
    )

    unresolved = [
      create_card_recommendation(offer_id: offer.id, person_id: person.id),
    ]

    expect(described_class.unresolved).to match_array(unresolved)
  end
end
