require 'rails_helper'

RSpec.describe CardRecommendation do
  example '#pull!' do
    card = create_card_account
    card.update!(recommended_at: Time.now)
    rec = described_class.new(card)
    rec.pull!
    expect(card.reload.pulled_at).to be_within(5.seconds).of(Time.now)
  end

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
end
