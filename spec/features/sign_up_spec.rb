require "rails_helper"

describe "the sign up page" do
  subject { page }

  before { visit new_account_registration_path }

  it "has fields to create a new account" do
    is_expected.to have_field :account_email
    is_expected.to have_field :account_password
    is_expected.to have_field :account_password_confirmation
  end

  describe "submitting the form" do
    let(:submit_form) { click_button "Sign up" }

    describe "with valid information for a new account" do
      before do
        fill_in :account_email, with: "testaccount@example.com"
        fill_in :account_password, with: "password123"
        fill_in :account_password_confirmation, with: "password123"
      end

      it "creates a new account" do
        expect{ submit_form }.to change{Account.count}.by(1)
      end

      describe "the created account" do
        before { submit_form }

        it "has the attributes I provided in the form" do
          account = Account.last
          expect(account.email).to eq "testaccount@example.com"
        end
      end

      describe "after creating an account" do
        before { submit_form }

        it "shows me the first page of the onboarding survey" do
          should have_field :survey_first_name
          should have_field :survey_last_name
        end
      end
    end

    describe "with invalid account information" do
      it "doesn't create a new account" do
        expect{ submit_form }.not_to change{Account.count}
      end
    end
  end
end
