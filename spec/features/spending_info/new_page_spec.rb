require "rails_helper"

describe "the spending info survey", :onboarding do
  subject { page }

  include ActiveJob::TestHelper

  let!(:account) do
    create(:account, :onboarded_type)
  end

  before do
    @person = account.owner
    @person.update_attributes!(eligible: true)
    login_as(account, scope: :account)
    visit new_person_spending_info_path(@person)
  end

  let(:person) { @person }
  let(:submit_form) { click_button "Save" }

  def create_companion!
    create(:spending_info, person: @person)
    @person.update_attributes!(onboarded_balances: true, onboarded_cards: true)
    @companion = create(:companion, :eligible, account: account)
  end

  example "page layout" do
    expect(page).to have_no_sidebar
    expect(page).to have_field :spending_info_credit_score
    expect(page).to have_field :spending_info_will_apply_for_loan_true
    expect(page).to have_field :spending_info_will_apply_for_loan_false
    expect(page).to have_field :spending_info_has_business_with_ein
    expect(page).to have_field :spending_info_has_business_without_ein
    expect(page).to have_field :spending_info_has_business_no_business, checked: true
    # Not initially visible:
    expect(page).to have_no_field :spending_info_business_spending_usd
    expect(page).to have_no_field :spending_info_unreadiness_reason
  end

  example "hiding and showing the business spending input", :js do
    choose :spending_info_has_business_with_ein
    expect(page).to have_field :spending_info_business_spending_usd
    choose :spending_info_has_business_no_business
    expect(page).to have_no_field :spending_info_business_spending_usd
    choose :spending_info_has_business_without_ein
    expect(page).to have_field :spending_info_business_spending_usd
    choose :spending_info_has_business_no_business
    expect(page).to have_no_field :spending_info_business_spending_usd
  end

  specify "don't save business spending when person has no business", :js do
    fill_in :spending_info_credit_score, with: 456

    choose :spending_info_has_business_with_ein
    fill_in :spending_info_business_spending_usd, with: 1234
    choose :spending_info_has_business_no_business

    expect { submit_form }.to change { SpendingInfo.count }.by(1)

    spending_info = SpendingInfo.last
    expect(spending_info.business_spending_usd).to be_blank
  end


  specify "submitting invalid form doesn't forget business info", :js do # bug fix
    choose :spending_info_has_business_with_ein
    expect { submit_form }.not_to change { SpendingInfo.count }
    expect(page).to have_field :spending_info_has_business_with_ein, checked: true
    expect(page).to have_field :spending_info_business_spending_usd
  end

  example "submitting valid info with no business" do
    fill_in :spending_info_credit_score, with: 456
    choose  :spending_info_will_apply_for_loan_true
    expect { submit_form }.to change { SpendingInfo.count }.by(1)

    new_info = SpendingInfo.last
    expect(new_info.credit_score).to eq 456
    expect(new_info.will_apply_for_loan).to be_truthy
    expect(new_info.has_business).to eq "no_business"
  end

  example "submitting valid info with business", :js do
    fill_in :spending_info_credit_score, with: 456
    choose  :spending_info_will_apply_for_loan_true
    choose  :spending_info_has_business_without_ein
    fill_in :spending_info_business_spending_usd, with: 5000
    expect { submit_form }.to change { SpendingInfo.count }.by(1)

    new_info = SpendingInfo.last
    expect(new_info.credit_score).to eq 456
    expect(new_info.will_apply_for_loan).to be_truthy
    expect(new_info.has_business).to eq "without_ein"
    expect(new_info.business_spending_usd).to eq 5000
  end

  specify "after submitting the form I'm taken to the card survey page" do
    fill_in :spending_info_credit_score, with: 456
    submit_form
    expect(current_path).to eq survey_person_card_accounts_path(person)
  end

  example "tracking intercom events for owner", :intercom do
    fill_in :spending_info_credit_score, with: 456
    expect{submit_form}.to \
      track_intercom_event("obs_spending_own").for_email(account.email)
    expect { submit_form }.to \
      track_intercom_event("obs_spending_own").for_email(account.email)
  end

  example "tracking intercom events for companion", :intercom do
    create_companion!
    visit new_person_spending_info_path(@companion)
    fill_in :spending_info_credit_score, with: 456
    expect { submit_form }.to \
      track_intercom_event("obs_spending_com").for_email(account.email)
  end

  example "submitting invalid information" do
    expect { submit_form }.not_to change { SpendingInfo.count }
    expect(page).to have_selector "form#new_spending_info"
    expect(page).to have_error_message
    # Bug fix: previously it was giving me both "can't be blank" and "not a
    # number"
    within ".alert.alert-danger" do
      expect(page).to have_content "Credit score can't be blank"
      expect(page).to have_no_content "Credit score is not a number"
    end
  end

  specify "don't lose previous 'will apply for loan' selection" do
    # Bug fix
    expect(page).to have_field :spending_info_will_apply_for_loan_false, checked: true
    submit_form
    expect(page).to have_field :spending_info_will_apply_for_loan_false, checked: true
    submit_form
    choose :spending_info_will_apply_for_loan_true
    submit_form
    expect(page).to have_field :spending_info_will_apply_for_loan_true, checked: true
  end

  example "show human-friendly error message for invalid business spending", :js do # bug fix
    choose :spending_info_has_business_with_ein
    submit_form
    within ".alert.alert-danger" do
      expect(page).to have_content "Business spending can't be blank"
    end
  end
end
