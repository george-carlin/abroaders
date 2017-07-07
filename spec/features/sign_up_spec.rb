require 'rails_helper'

RSpec.describe 'the sign up page', :onboarding, :auth do
  before { visit new_account_registration_path }

  let(:submit_form) { click_button 'Sign up' }

  example 'form' do
    expect(page).to have_field :account_email
    expect(page).to have_field :account_password
    expect(page).to have_field :account_password_confirmation
    expect(page).to have_field :account_first_name
  end

  describe 'valid signup' do
    let(:new_account) { Account.last }
    let(:new_person)  { new_account.owner }

    before do # fill in form with valid info:
      fill_in :account_email,    with: 'TestAccount@example.com'
      fill_in :account_password, with: 'password123'
      fill_in :account_password_confirmation, with: 'password123'
      fill_in :account_first_name, with: 'Luke'
    end

    it 'creates a new account with 1 person' do
      expect { submit_form }.to change { Account.count }.by(1)
      expect(new_account.people.count).to eq 1
      # saves email in lower case:
      expect(new_account.email).to eq 'testaccount@example.com'

      # takes me to first page of onboarding survey:
      expect(current_path).to eq survey_home_airports_path
    end

    it "sends an email to the admin with the new user's email address" do
      old = ENV['SEND_ADMIN_SIGN_UP_NOTIFICATION_EMAIL']
      ENV['SEND_ADMIN_SIGN_UP_NOTIFICATION_EMAIL'] = 'true'
      expect { submit_form }.to change { enqueued_jobs.size }
      expect do
        perform_enqueued_jobs { ActionMailer::DeliveryJob.perform_now(*enqueued_jobs.first[:args]) }
      end.to change { ApplicationMailer.deliveries.length }.by(1)

      email = ApplicationMailer.deliveries.last
      expect(email.to).to match_array [ENV['MAILPARSER_NEW_SIGNUP']]

      ENV['SEND_ADMIN_SIGN_UP_NOTIFICATION_EMAIL'] = old
    end

    example "can't visit sign up page when signed in" do
      submit_form

      visit new_account_registration_path

      expect(current_path).not_to eq new_account_registration_path
    end
  end
end
