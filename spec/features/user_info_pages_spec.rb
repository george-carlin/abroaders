require "rails_helper"

describe "user info pages" do
  subject { page }

  include_context "logged in as new user"

  describe "new page" do
    before do
      extra_setup
      visit survey_path
    end

    let(:extra_setup) { nil }

    it "has fields for contact info" do
      should have_field :user_info_first_name
      should have_field :user_info_middle_names
      should have_field :user_info_last_name
      should have_field :user_info_phone_number
      should have_field :user_info_whatsapp
      should have_field :user_info_text_message
      should have_field :user_info_imessage
      should have_field :user_info_time_zone
      should have_field :user_info_citizenship_us_citizen
      should have_field :user_info_citizenship_us_permanent_resident
      should have_field :user_info_citizenship_neither
      should have_field :user_info_credit_score
      should have_field :user_info_will_apply_for_loan_true
      should have_field :user_info_will_apply_for_loan_false
      should have_field :user_info_spending_per_month_dollars
      should have_field :user_info_has_business_with_ein
      should have_field :user_info_has_business_without_ein
      should have_field :user_info_has_business_no_business
    end


    describe "submitting the form" do
      let(:submit_form) { click_button "Save" }

      context "with valid information" do
        before do
          fill_in :user_info_first_name,   with: "Fred"
          fill_in :user_info_last_name,    with: "Bloggs"
          fill_in :user_info_phone_number, with: "0123412341"
          select "(GMT+00:00) London", from: :user_info_time_zone
          choose :user_info_citizenship_us_permanent_resident
          fill_in :user_info_credit_score, with: "456"
          choose :user_info_will_apply_for_loan_true
          fill_in :user_info_spending_per_month_dollars, with: "1500"
          choose :user_info_has_business_without_ein
        end

        it "saves the user's information" do
          expect(user.info).not_to be_persisted
          submit_form
          user_info = user.reload.info
          expect(user_info).to be_persisted
          expect(user_info.first_name).to eq "Fred"
          expect(user_info.last_name).to eq "Bloggs"
          expect(user_info.phone_number).to eq "0123412341"
          expect(user_info.time_zone).to eq "London"
          expect(user_info.citizenship).to eq "us_permanent_resident"
          expect(user_info.credit_score).to eq 456
          expect(user_info.will_apply_for_loan).to be_truthy
          expect(user_info.spending_per_month_dollars).to eq 1500
          expect(user_info.has_business).to eq "without_ein"
        end

        it "takes me to the cards survey page" do
          submit_form
          expect(current_path).to eq card_survey_path
        end
      end

      context "with invalid information" do
        it "doesn't saves the user's information" do
          submit_form
          expect(user.reload.info).to be_nil
        end
      end
    end # submitting the form


    context "when I already have provided my user  info" do
      let(:extra_setup) { create(:user_info, user: user) }
      it "redirects to root" do
        # TODO this should probably be changed once we add the ability to
        # *edit* contact info
        expect(current_path).to eq root_path
      end
    end

  end
end
