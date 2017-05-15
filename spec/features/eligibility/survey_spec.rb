require "rails_helper"

RSpec.describe "eligibility" do
  let(:account) { create_account(onboarding_state: 'eligibility') }
  let(:owner)   { account.owner }
  before { login_as(account) }

  describe "survey" do
    let(:click_submit) { click_button "Save and continue" }

    context "for a couples account" do
      let!(:companion) { create_companion(account: account) }
      before { visit survey_eligibility_path }

      it "has four options" do
        expect(page).to have_field :eligibility_survey_eligible_both
        expect(page).to have_field :eligibility_survey_eligible_owner
        expect(page).to have_field :eligibility_survey_eligible_companion
        expect(page).to have_field :eligibility_survey_eligible_neither
      end

      example "selecting 'both'" do
        choose :eligibility_survey_eligible_both
        click_submit
        expect(account.owner.reload).to be_eligible
        expect(account.companion.reload).to be_eligible
        expect(account.reload.onboarding_state).to eq "owner_cards"
        expect(current_path).to eq survey_person_cards_path(account.owner)
      end

      example "selecting 'owner'" do
        choose :eligibility_survey_eligible_owner
        click_submit
        expect(account.owner.reload).to be_eligible
        expect(account.companion.reload).not_to be_eligible
        expect(account.reload.onboarding_state).to eq "owner_cards"
        expect(current_path).to eq survey_person_cards_path(account.owner)
      end

      example "selecting 'companion'" do
        choose :eligibility_survey_eligible_companion
        click_submit
        expect(account.owner.reload).not_to be_eligible
        expect(account.companion.reload).to be_eligible
        expect(account.reload.onboarding_state).to eq "owner_balances"
        expect(current_path).to eq survey_person_balances_path(account.owner)
      end

      example "selecting 'neither'" do
        choose :eligibility_survey_eligible_neither
        click_submit
        expect(account.owner.reload).not_to be_eligible
        expect(account.companion.reload).not_to be_eligible
        expect(account.reload.onboarding_state).to eq "owner_balances"
        expect(current_path).to eq survey_person_balances_path(account.owner)
      end
    end

    context "for a solo account" do
      before { visit survey_eligibility_path }

      it "has two options" do
        expect(page).to have_field :eligibility_survey_eligible_owner
        expect(page).to have_field :eligibility_survey_eligible_neither
        expect(page).to have_no_field :eligibility_survey_eligible_both
        expect(page).to have_no_field :eligibility_survey_eligible_companion
      end

      example "selecting 'I am eligible'" do
        choose :eligibility_survey_eligible_owner
        click_submit
        expect(account.owner.reload).to be_eligible
        expect(account.reload.onboarding_state).to eq "owner_cards"
        expect(current_path).to eq survey_person_cards_path(owner)
      end

      example "selecting 'owner'" do
        choose :eligibility_survey_eligible_neither
        click_submit
        expect(account.owner.reload).not_to be_eligible
        expect(account.reload.onboarding_state).to eq "owner_balances"
        expect(current_path).to eq survey_person_balances_path(owner)
      end
    end
  end
end
