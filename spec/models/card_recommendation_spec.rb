require 'rails_helper'

RSpec.describe CardRecommendation do
  example '#actionable?' do
    time = Time.now
    rec  = described_class.new(Card.new(recommended_at: time))
    expect(rec.actionable?).to be true
    rec.pulled_at = time
    expect(rec.actionable?).to be false
    rec.pulled_at = nil
    rec.expired_at = time
    expect(rec.actionable?).to be false
    rec.expired_at = nil
    rec.declined_at = time
    expect(rec.actionable?).to be false
    rec.declined_at = nil
    rec.applied_on = time
    expect(rec.actionable?).to be true
    rec.denied_at = time
    expect(rec.actionable?).to be true
    rec.redenied_at = time
    expect(rec.actionable?).to be false
    rec.redenied_at = nil
    rec.nudged_at = time
    expect(rec.actionable?).to be false
    rec.denied_at = nil
    expect(rec.actionable?).to be true
    rec.called_at = time
    expect(rec.actionable?).to be true
    rec.denied_at = time
    expect(rec.actionable?).to be false
    rec.denied_at = nil
    allow(rec).to receive(:unopen?).and_return(false)
    expect(rec.actionable?).to be false
  end

  describe '#status' do
    let(:date) { Time.zone.today }

    # possible values: [recommended, declined, applied, denied, expired, pulled]
    let(:attrs) { { recommended_at: date } }

    subject { described_class.new(Card.new(attrs)).status }

    it { is_expected.to eq 'recommended' }

    context 'when pulled_at is present' do
      before { attrs[:pulled_at] = date }
      it { is_expected.to eq 'pulled' }
    end

    context 'when expired_at is present' do
      before { attrs[:expired_at] = date }
      it { is_expected.to eq 'expired' }
    end

    context 'when applied_on is present' do
      before { attrs[:applied_on] = date }

      context 'and denied_at is present' do
        before { attrs[:denied_at] = date }
        it { is_expected.to eq 'denied' }
      end

      context 'and denied_at is nil' do
        it { is_expected.to eq 'applied' }
      end
    end

    context 'when declined_at is present' do
      before { attrs[:declined_at] = date }
      it { is_expected.to eq 'declined' }
    end
  end
end
