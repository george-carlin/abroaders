require "rails_helper"

describe "travel plans survey" do

  let(:account) { create(:account, onboarding_stage: "travel_plans") }
  include_context "travel plan form"

  before { visit survey_travel_plan_path }

  it_behaves_like "a travel plan form"

  describe "submitting a valid travel plan" do
    before do
      fill_in_form_with_valid_information
      submit_form
    end

    it "marks my account's onboarding stage as 'passengers'" do
      expect(account.reload.onboarding_stage).to eq "passengers"
    end

    it "takes me to the passengers survey" do
      expect(current_path).to eq survey_passengers_path
    end
  end

  describe "submitting an invalid travel plan" do
    it "doesn't change my account's onboarding stage" do
      expect{submit_form}.not_to change{account.reload.onboarding_stage}
    end
  end
end
