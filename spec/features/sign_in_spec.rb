require "rails_helper"

describe "the sign in page" do
  subject { page }

  before do
    @pw      = "foobar123"
    @account = create(:account, password: @pw, password_confirmation: @pw)
    visit new_account_session_path
  end

  it "has fields for signing in" do
    is_expected.to have_field :account_email
    is_expected.to have_field :account_password
  end

  describe "submitting the form" do
    let(:submit_form) { click_button "Sign in" }

    describe "with my valid logon details" do
      before do
        fill_in :account_email,    with: @account.email
        fill_in :account_password, with: @pw
        submit_form
      end

      it "signs me in" do
        expect(page).to have_content "Sign out"
        expect(page).to have_content @account.email
        expect(page).not_to have_content "Sign in"
      end
    end

    describe "with invalid logon details" do
      before { submit_form }
      it "doesn't sign me in" do
        expect(page).to have_content "Sign in"
        expect(page).not_to have_content "Sign out"
        expect(page).not_to have_content @account.email
      end
    end
  end
end
