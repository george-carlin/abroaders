require 'rails_helper'

RSpec.describe CardRecommendation do
  example '#pull!' do
    card = create_card
    card.update!(recommended_at: Time.now)
    rec  = described_class.new(card)
    rec.pull!
    expect(card.reload.pulled_at).to be_within(5.seconds).of(Time.now)
  end
end
