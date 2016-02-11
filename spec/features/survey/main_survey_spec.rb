require "rails_helper"

describe "user main survey" do
  subject { page }

  include_context "logged in as new user"

  before do
    extra_setup
    visit survey_path
  end

  let(:extra_setup) { nil }

  it "has fields for contact info" do
    should have_field :survey_first_name
    should have_field :survey_middle_names
    should have_field :survey_last_name
    should have_field :survey_phone_number
    should have_field :survey_whatsapp
    should have_field :survey_text_message
    should have_field :survey_imessage
    should have_field :survey_time_zone
    should have_field :survey_citizenship_us_citizen
    should have_field :survey_citizenship_us_permanent_resident
    should have_field :survey_citizenship_neither
    should have_field :survey_credit_score
    should have_field :survey_will_apply_for_loan_true
    should have_field :survey_will_apply_for_loan_false
    should have_field :survey_personal_spending
    should have_field :survey_has_business_with_ein
    should have_field :survey_has_business_without_ein
    should have_field :survey_has_business_no_business
  end

  describe "the 'business spending' input" do
    it "appears iff I say that I have a business", js: true do
      is_expected.not_to have_field :survey_business_spending
      choose :survey_has_business_with_ein
      is_expected.to have_field :survey_business_spending
      choose :survey_has_business_without_ein
      is_expected.to have_field :survey_business_spending
      choose :survey_has_business_no_business
      is_expected.not_to have_field :survey_business_spending
    end
  end

  describe "the 'time zone' dropdown" do
    it "has US time zones sorted to the top" do
      us_zones = ActiveSupport::TimeZone.us_zones.map(&:name)
      options  = all("select[name='survey[time_zone]'] > option")
      expect(options.first(us_zones.length).map(&:value)).to \
        match_array(us_zones)
    end
  end

  describe "submitting the form" do
    let(:submit_form) { click_button "Save" }

    context "with valid information" do
      before do
        fill_in :survey_first_name,   with: "Fred"
        fill_in :survey_last_name,    with: "Bloggs"
        fill_in :survey_phone_number, with: "0123412341"
        select "(GMT+00:00) London", from: :survey_time_zone
        choose  :survey_citizenship_us_permanent_resident
        fill_in :survey_credit_score, with: "456"
        choose  :survey_will_apply_for_loan_true
        fill_in :survey_personal_spending, with: "1500"
        choose  :survey_has_business_without_ein
      end

      it "saves the user's information" do
        expect(user.survey).not_to be_persisted
        submit_form
        survey = user.reload.survey
        expect(survey).to be_persisted
        expect(survey.first_name).to eq "Fred"
        expect(survey.last_name).to eq "Bloggs"
        expect(survey.phone_number).to eq "0123412341"
        expect(survey.time_zone).to eq "London"
        expect(survey.citizenship).to eq "us_permanent_resident"
        expect(survey.credit_score).to eq 456
        expect(survey.will_apply_for_loan).to be_truthy
        expect(survey.personal_spending).to eq 1500
        expect(survey.has_business).to eq "without_ein"
      end

      it "takes me to the cards survey page" do
        submit_form
        expect(current_path).to eq survey_card_accounts_path
      end
    end

    context "with invalid information" do
      it "doesn't saves the user's information" do
        submit_form
        expect(user.reload.survey).to be_nil
      end
    end
  end # submitting the form
end
