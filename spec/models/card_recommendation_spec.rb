require 'rails_helper'

RSpec.describe CardRecommendation do
  example '#pull!' do
    card = create(:card, recommended_at: Time.now, pulled_at: nil)
    rec  = described_class.new(card)
    rec.pull!
    expect(card.reload.pulled_at).to be_within(5.seconds).of(Time.now)
  end
end
