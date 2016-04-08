require "rails_helper"

describe "the sign up page" do
  subject { page }

  before { visit new_account_registration_path }

  it "has fields to create a new account" do
    is_expected.to have_field :sign_up_email
    is_expected.to have_field :sign_up_password
    is_expected.to have_field :sign_up_password_confirmation
    is_expected.to have_field :sign_up_first_name
  end

  describe "submitting the form" do
    let(:submit_form) { click_button "Sign up" }

    def fill_in_valid_info
      fill_in :sign_up_email,    with: "TestAccount@example.com"
      fill_in :sign_up_password, with: "password123"
      fill_in :sign_up_password_confirmation, with: "password123"
      fill_in :sign_up_first_name, with: "Luke"
    end

    def self.it_doesnt_create_a_new_account
      it "doesn't create a new account" do
        expect{ submit_form }.not_to change{Account.count}
      end
    end

    describe "with valid information for a new account" do
      before { fill_in_valid_info }

      it "creates a new account with 1 passenger" do
        expect{ submit_form }.to change{Account.count}.by(1)
        expect(Account.last.passengers.count).to eq 1
      end

      it "saves my email in lower case" do
        # This is the case for a very deliberate reason - the uniqueness
        # validation on Account#email only checks against lowercase strings.
        # This is to save us having to make a case-insensitive index on
        # Account#email. If you allow non-lowercase emails to be saved in the
        # DB, we may end up with accounts with duplicate emails!
        submit_form
        expect(Account.last.email).to eq "testaccount@example.com"
      end

      describe "the created account" do
        before { submit_form }

        it "has the attributes I provided in the form" do
          account = Account.last
          expect(account.email).to eq "testaccount@example.com"
          expect(account.main_passenger.first_name).to eq "Luke"
        end
      end

      describe "after creating an account" do
        before { submit_form }

        it "shows me the first page of the onboarding survey" do
          expect(current_path).to eq survey_travel_plan_path
        end
      end

      describe "and trailing whitespace for name and email" do
        before do
          fill_in :sign_up_email,      with: " testaccount@example.com "
          fill_in :sign_up_first_name, with: " Luke "
          submit_form
        end

        it "strips the whitespace before save" do
          account = Account.last
          expect(account.email).to eq "testaccount@example.com"
          expect(account.main_passenger.first_name).to eq "Luke"
        end
      end
    end

    describe "with mismatching passwords" do
      before do
        fill_in_valid_info
        fill_in :sign_up_password_confirmation, with: "mismatch"
      end

      it_doesnt_create_a_new_account
    end

    describe "with an email address that has already been taken" do
      describe "by another " do
        before { create(:account, email: "TestAccount@EXAMPLE.com") }
        it_doesnt_create_a_new_account
      end

      describe "by an admin" do
        before { create(:admin, email: "TestAccount@EXAMPLE.com") }
        it_doesnt_create_a_new_account
      end
    end

    describe "with invalid account information" do
      it_doesnt_create_a_new_account
    end
  end
end
