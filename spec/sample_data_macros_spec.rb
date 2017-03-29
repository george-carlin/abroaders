require 'rails_helper'

RSpec.describe SampleDataMacros do
  example "#create_card_recommendation" do
    expect { create_card_recommendation }.to change { CardRecommendation.count }.by(1)
  end

  example '#create_card' do
    expect { create_card }.to change { Card.count }.by(1)

    expect { create_card(:closed) }.to change { Card.count }.by(1)
    expect(Card.last.closed_on).not_to be_nil
  end
end
