require "rails_helper"

describe "travel plans page" do

  let(:account) { create(:account, onboarding_stage: "onboarded") }
  include_context "travel plan form"

  before { visit new_travel_plan_path }

  it_behaves_like "a travel plan form"

  describe "submitting a valid travel plan" do
    before do
      fill_in_form_with_valid_information
      submit_form
    end

    it "takes me to the travel plans index" do
      expect(current_path).to eq travel_plans_path
    end
  end
end
