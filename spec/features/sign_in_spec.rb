require "rails_helper"

RSpec.describe "the sign in page" do
  before do
    @pw = "foobar123"
    attrs = { password: @pw, password_confirmation: @pw }
    @account = create(:account, :onboarded, attrs)
    visit new_account_session_path
  end

  it "has fields for signing in" do
    expect(page).to have_field :account_email
    expect(page).to have_field :account_password
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
        expect(page).to have_selector "#sign_out_link"
        expect(page).to have_content @account.email
        expect(page).to have_no_content "Sign in"
        expect(current_path).to eq root_path
      end
    end

    describe "with invalid logon details" do
      before { submit_form }
      it "doesn't sign me in" do
        expect(page).to have_content "Sign in"
        expect(page).to have_no_selector "#sign_out_link"
        expect(page).to have_no_content @account.email
      end
    end
  end
end
