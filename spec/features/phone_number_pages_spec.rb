require 'rails_helper'

RSpec.describe 'phone number pages' do
  let!(:account) { create_account(onboarding_state: 'phone_number') }
  before { login_as_account(account) }

  let(:submit_form) { click_button 'Save and continue' }

  describe 'new page' do
    before { visit new_phone_number_path }

    example 'submitting a phone number' do
      # saves phone number and completes onboarding survey
      fill_in :account_phone_number, with: '555 000-1234'
      submit_form
      expect(current_path).to eq root_path
    end

    example 'submitting with no phone number' do
      # doesn't continue; shows page again with error message
      submit_form
      expect(account.reload.phone_number).to be nil
      expect(page).to have_error_message(
        "Error: Phone number must be filled and size cannot be greater than 15. "\
        "Please click the 'Skip' button if you do not wish to add a phone number",
      )
    end

    example 'skipping the page' do
      # doesn't save a phone number, completes onboarding survey
      expect { click_link "Skip" }.to \
        send_email.to(ENV['MAILPARSER_SURVEY_COMPLETE'])
        .with_subject("App Profile Complete - #{account.email}")
      expect(account.reload.phone_number).to be nil
    end
  end
end
