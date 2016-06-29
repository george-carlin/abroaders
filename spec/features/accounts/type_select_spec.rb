require "rails_helper"

describe "account type select page", :js, :onboarding do
  subject { page }

  let(:account) { create(:account, :onboarded_travel_plans) }
  let!(:me) { account.owner }

  let(:onboarded_travel_plans) { true }

  before do
    login_as_account(account)
    extra_setup
    visit type_account_path
  end

  let(:form) { AccountTypeFormOnPage.new(self) }

  let(:extra_setup) { nil }

  def track_intercom_event
    super("obs_account_type").for_email(account.email)
  end

  def expect_survey_to_be_marked_as_complete
    expect(account.reload.onboarded_type?).to be true
  end

  def expect_survey_not_to_be_marked_as_complete
    expect(account.reload.onboarded_type?).to be false
  end

  it { is_expected.to have_title full_title("Select Account Type") }

  it "gives me the option to choose a 'Solo' or 'Partner' account" do
    expect(form).to have_solo_btn
    expect(form).to have_couples_btn
    is_expected.to have_field :partner_account_partner_first_name
  end

  it "has no sidebar" do
    expect(page).to have_no_sidebar
  end

  context "when I skipped adding a travel plan" do
    it { is_expected.to have_content "Abroaders will help you earn the right points for your next trip" }
  end

  describe "selecting 'solo'" do
    before { form.click_solo_btn }

    it "shows the solo form and hides the rest" do
      expect(form).to have_no_couples_form
      expect(form).to have_no_solo_btn
      expect(page).to have_field :solo_account_monthly_spending_usd
      is_expected.to have_field :solo_account_eligible_true
      is_expected.to have_field :solo_account_eligible_false
    end

    example "hiding and showing the solo monthly spending input" do
      choose "No - I am not eligible"
      # hides the monthly spending input
      is_expected.to have_no_field :solo_account_monthly_spending_usd
      # clicking 'eligible' show the monthly spending input again
      choose "Yes - I am eligible"
      is_expected.to have_field :solo_account_monthly_spending_usd
    end

    example "submitting when I'm not eligible to apply" do
      choose "No - I am not eligible"
      # saves my information:
      expect do
        form.click_confirm_btn
      end.to change{Person.count}.by(0).and track_intercom_event
      account.reload
      expect(account.monthly_spending_usd).to be_nil
      expect(me.reload).to be_ineligible
      expect(current_path).to eq survey_person_balances_path(me)
      expect_survey_to_be_marked_as_complete
    end

    example "submitting without adding a monthly spend" do
      person_count_before = Person.count
      expect do
        form.click_confirm_btn
        account.reload
      end.not_to change{account.attributes}
      # no people have been created:
      expect(person_count_before).to eq Person.count

      expect_survey_not_to_be_marked_as_complete

      # shows me the form again with an error message"
      expect(page).to have_error_message
      expect(form).to have_no_solo_btn
      is_expected.to have_field :solo_account_monthly_spending_usd
      is_expected.to have_field :solo_account_eligible_true
      is_expected.to have_field :solo_account_eligible_false
      expect(form).to have_confirm_btn
    end

    example "submitting when I am eligible" do
      fill_in :solo_account_monthly_spending_usd, with: 1000

      expect do
        form.click_confirm_btn
      end.to change{Person.count}.by(0).and track_intercom_event
      account.reload
      expect(account.monthly_spending_usd).to eq 1000
      expect(me.reload).to be_eligible
      expect(current_path).to eq new_person_spending_info_path(me)
      expect_survey_to_be_marked_as_complete
    end
  end

  describe "choosing 'couples'" do
    let(:partner_name) { "Steve" }

    example "without providing a partner name" do
      form.click_couples_btn
      # shows an error message and doesn't continue:
      expect(page).to have_error_message
      expect(form.show_partner_form_step_0?).to be true
      # providing a name and clicking again:
      form.fill_in_partner_first_name with: partner_name
      form.click_couples_btn
      expect(page).to have_no_error_message
      expect(form.show_partner_form_step_1?).to be true
    end

    example "providing a name with trailing whitespace" do
      form.fill_in_partner_first_name with: "    Steve   "
      form.click_couples_btn
      # strips the whitespace:
      expect(form).to have_content "Only Steve is eligible"
    end

    example "providing a partner name" do
      form.fill_in_partner_first_name with: partner_name
      form.click_couples_btn
      # hides the solo form
      expect(form).to have_no_solo_form
      # shows the next step:
      expect(form.show_partner_form_step_1?).to be true
      # shows the partner's name:
      expect(form).to have_content "Only Steve is eligible"
    end

    example "submitting when neither person is eligible" do
      form.fill_in_partner_first_name with: partner_name
      form.click_couples_btn
      choose :partner_account_eligibility_neither
      # hides the monthly spending input
      expect(page).to have_no_field :partner_account_monthly_spending_usd
      # shows the monthly spending input again
      choose :partner_account_eligibility_both
      expect(page).to have_field :partner_account_monthly_spending_usd
      choose :partner_account_eligibility_neither
      # adds a partner to my account:
      expect do
        form.click_confirm_btn
      end.to change{account.people.count}.by(1).and track_intercom_event
      # saves partner name correctly:
      expect(account.partner.first_name).to eq partner_name
      # marks me and my partner as ineligible to apply:
      expect(account.people.all?(&:ineligible?)).to be true
      # takes me to my balances survey:
      expect(current_path).to eq survey_person_balances_path(me)
      expect_survey_to_be_marked_as_complete
    end

    example "submitting when only one person is eligible" do
      form.fill_in_partner_first_name with: partner_name
      form.click_couples_btn
      form.choose_partner_eligibility_person_0
      expect(form).to have_content \
        "Only #{me.first_name} will receive credit card recommendations"
      form.choose_partner_eligibility_person_1
      expect(form).to have_content \
        "Only #{partner_name} will receive credit card recommendations"
    end

    example "submitting when only I am eligible" do
      form.fill_in_partner_first_name with: partner_name
      form.click_couples_btn
      form.choose_partner_eligibility_person_0
      form.fill_in_couples_monthly_spending with: 1234
      # adds a partner to my account:
      expect do
        form.click_confirm_btn
      end.to change{account.people.count}.by(1).and track_intercom_event
      account.reload
      expect(account.partner.first_name).to eq partner_name
      # saves our monthly spending:
      expect(account.monthly_spending_usd).to eq 1234
      # saves who's eligible to apply:
      expect(account.owner).to be_eligible
      expect(account.partner).to be_ineligible
      # takes me to my spending survey
      expect(current_path).to eq new_person_spending_info_path(me)
      expect_survey_to_be_marked_as_complete
    end

    example "submitting when only my partner is eligible" do
      form.fill_in_partner_first_name with: partner_name
      form.click_couples_btn
      form.choose_partner_eligibility_person_1
      form.fill_in_couples_monthly_spending with: 1234
      # adds a partner to my account:
      expect do
        form.click_confirm_btn
      end.to change{account.people.count}.by(1).and track_intercom_event
      account.reload
      expect(account.partner.first_name).to eq partner_name
      # saves our monthly spending:
      expect(account.monthly_spending_usd).to eq 1234
      # saves who's eligible to apply:
      expect(account.owner).to be_ineligible
      expect(account.partner).to be_eligible
      # takes me to my balances survey
      expect(current_path).to eq survey_person_balances_path(me)
      expect_survey_to_be_marked_as_complete
    end

    example "submitting when we are both eligible" do
      form.fill_in_partner_first_name with: partner_name
      form.click_couples_btn
      form.fill_in_couples_monthly_spending with: 2345

      expect do
        form.click_confirm_btn
      end.to change{account.people.count}.by(1).and track_intercom_event

      account.reload
      # saves partner first name:
      expect(account.partner.first_name).to eq partner_name
      # saves monthly spending
      expect(account.reload.monthly_spending_usd).to eq 2345
      # saves eligibility:
      expect(account.owner).to be_eligible
      expect(account.partner).to be_eligible
      # takes me to my spending survey" do
      expect(current_path).to eq new_person_spending_info_path(me)
      expect_survey_to_be_marked_as_complete
    end

    example "submitting without adding monthly spending" do
      form.fill_in_partner_first_name with: partner_name
      form.click_couples_btn
      expect do
        form.click_confirm_btn
      end.not_to change{account.people.count}
      account.reload
      expect(account.monthly_spending_usd).to be_nil
      expect(me.onboarded_eligibility?).to be false
      expect(me.onboarded_eligibility?).to be false
      expect_survey_not_to_be_marked_as_complete
    end
  end
end
