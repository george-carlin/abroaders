require "rails_helper"

describe "spending info pages" do
  subject { page }

  include_context "logged in as new user"

  before { user.create_contact_info!(attributes_for(:contact_info)) }

  describe "new page" do
    before do
      visit new_spending_info_path
    end

    it "has fields for spending info" do
      should have_field :spending_info_citizenship_us_citizen
      should have_field :spending_info_citizenship_us_permanent_resident
      should have_field :spending_info_citizenship_neither
      should have_field :spending_info_credit_score
      should have_field :spending_info_will_apply_for_loan_true
      should have_field :spending_info_will_apply_for_loan_false
      should have_field :spending_info_spending_per_month_dollars
      should have_field :spending_info_has_business_with_ein
      should have_field :spending_info_has_business_without_ein
      should have_field :spending_info_has_business_no_business
    end

    describe "submitting the form" do
      let(:submit_form) { click_button "Save" }

      context "with valid information" do
        before do
          fill_in :spending_info_credit_score, with: "400"
          fill_in :spending_info_spending_per_month_dollars, with: "1500"
        end

        it "saves the spending info" do
          expect(user.spending_info).not_to be_persisted
          submit_form
          expect(user.reload.spending_info).to be_persisted
        end
      end
    end
  end
end
