require "rails_helper"

describe "the sign up page", :onboarding do
  before { visit new_account_registration_path }

  it "has fields to create a new account" do
    expect(page).to have_field :sign_up_email
    expect(page).to have_field :sign_up_password
    expect(page).to have_field :sign_up_password_confirmation
    expect(page).to have_field :sign_up_first_name
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
        expect { submit_form }.not_to change { Account.count }
      end
    end

    describe "with valid information for a new account" do
      before { fill_in_valid_info }

      let(:new_account) { Account.last }
      let(:new_person)  { new_account.people.first }

      it "creates a new account with 1 person" do
        expect { submit_form }.to change { Account.count }.by(1)
        expect(new_account.people.count).to eq 1
      end

      it "saves my email in lower case" do
        # This is the case for a very deliberate reason - the uniqueness
        # validation on Account#email only checks against lowercase strings.
        # This is to save us having to make a case-insensitive index on
        # Account#email. If you allow non-lowercase emails to be saved in the
        # DB, we may end up with accounts with duplicate emails!
        submit_form
        expect(new_account.email).to eq "testaccount@example.com"
      end

      it "sends an email to the admin with the new user's email address" do
        expect { submit_form }.to change { enqueued_jobs.size }
        expect do
          perform_enqueued_jobs { ActionMailer::DeliveryJob.perform_now(*enqueued_jobs.first[:args]) }
        end.to change { ApplicationMailer.deliveries.length }.by(1)

        email = ApplicationMailer.deliveries.last
        expect(email.to).to match_array [ENV['MAILPARSER_NEW_SIGNUP']]
      end

      it "creates a user on Intercom", :intercom do
        expect(enqueued_jobs).to be_empty
        expect { submit_form }.to change { enqueued_jobs.size }
        job = enqueued_jobs.detect { |j| j[:job] == IntercomJobs::CreateUser }
        expect(job).not_to be_nil
        expect(job[:args][0]["account_id"]).to eq Account.last.id
      end

      describe "the created account" do
        before { submit_form }

        it "has the attributes I provided in the form" do
          expect(new_account.email).to eq "testaccount@example.com"
          expect(new_person.first_name).to eq "Luke"
        end
      end

      describe "after creating an account" do
        before { submit_form }

        it "shows me the first page of the onboarding survey" do
          expect(current_path).to eq survey_home_airports_path
        end
      end

      describe 'and trailing whitespace for name and email' do
        before do
          fill_in :sign_up_email,      with: ' testaccount@example.com '
          fill_in :sign_up_first_name, with: ' Luke '
          submit_form
        end

        it 'strips the whitespace before save' do
          expect(new_account.email).to eq 'testaccount@example.com'
          expect(new_person.first_name).to eq 'Luke'
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
