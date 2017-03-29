require 'rails_helper'

RSpec.describe SampleDataMacros do
  example "#create_card_recommendation" do
    expect { create_card_recommendation }.to change { CardRecommendation.count }.by(1)
  end
end
