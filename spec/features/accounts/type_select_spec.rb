require "rails_helper"

describe "account type select page", :js, :onboarding do
  subject { page }

  let(:account) { create(:account, onboarding_state: :account_type) }
  let(:owner) { account.owner }

  before do
    login_as_account(account)
    visit type_account_path
  end

  let(:form) { AccountTypeFormOnPage.new(self) }

  def track_intercom_event
    super("obs_account_type").for_email(account.email)
  end

  it { is_expected.to have_title full_title("Select Account Type") }

  it "gives me the option to choose a 'Solo' or 'Partner' account" do
    expect(form).to have_solo_btn
    expect(form).to have_couples_btn
    expect(page).to have_field :account_companion_first_name
  end

  it "has no sidebar" do
    expect(page).to have_no_sidebar
  end

  example "choosing 'solo'" do
    expect do
      form.click_solo_btn
    end.to change { Person.count }.by(0).and track_intercom_event
    account.reload
    expect(account.onboarding_state).to eq "eligibility"

    expect(current_path).to eq survey_eligibility_path
  end

  describe "choosing 'couples'" do
    let(:companion_name) { "Steve" }

    example "without providing a companion name" do
      expect do
        form.click_couples_btn
      end.not_to change { Person.count }
      # shows an error message and doesn't continue:
      expect(page).to have_error_message
    end

    example "submitting whitespace as companion name" do
      # strips the whitespace:
      expect do
        form.submit_companion_first_name("     ")
      end.not_to change { Person.count }
      expect(page).to have_error_message
    end

    example "providing a companion name" do
      expect do
        form.submit_companion_first_name(companion_name)
      end.to change { Person.count }.by(1)
      account.reload
      expect(account.companion.first_name).to eq companion_name

      expect(account.onboarding_state).to eq "eligibility"
      expect(current_path).to eq survey_eligibility_path
    end

    example "providing a name with trailing whitespace" do
      # strips the whitespace:
      expect do
        form.submit_companion_first_name("     Steve   ")
      end.to change { Person.count }.by(1)
      account.reload
      expect(account.companion.first_name).to eq "Steve"
    end
  end
end
