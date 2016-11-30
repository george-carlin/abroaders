require 'rails_helper'

describe 'phone number pages' do
  let!(:account) { create(:account, onboarding_state: :phone_number) }
  before { login_as_account(account) }

  let(:submit_form) { click_button 'Save and continue' }

  describe 'new page' do
    before { visit new_phone_number_path }

    example 'submitting a phone number' do
      fill_in :phone_number_number, with: '555 000-1234'
      submit_form
      account.reload
      expect(account.phone_number.number).to eq '555 000-1234'
      expect(account.phone_number.normalized_number).to eq '5550001234'
      expect(account.onboarding_state).to eq 'complete'
      expect(current_path).to eq root_path
    end

    example 'notifying the admin that the survey is complete' do
      fill_in :phone_number_number, with: '555 000-1234'
      expect { submit_form }.to \
        send_email.to(ENV['MAILPARSER_SURVEY_COMPLETE'])
        .with_subject("App Profile Complete - #{account.email}")
    end

    example "submitting a phone number with trailing whitespace" do
      fill_in :phone_number_number, with: "  555 000-1234  "
      submit_form
      account.reload
      expect(account.phone_number.number).to eq '555 000-1234'
      expect(account.phone_number.normalized_number).to eq '5550001234'
      expect(account.onboarding_state).to eq 'complete'
      expect(current_path).to eq root_path
    end

    example "submitting with no phone number" do
      submit_form
      account.reload
      expect(account.phone_number).to be_nil
      expect(page).to have_error_message(
        "Error: Phone number must be filled and size cannot be greater than 15. "\
        "Please click the 'Skip' button if you do not wish to add a phone number",
      )
    end

    example "submitting a whitespace-only phone number" do
      fill_in :phone_number_number, with: "       "
      submit_form
      account.reload
      expect(account.phone_number).to be_nil
      expect(page).to have_error_message
    end

    example "skipping the form" do
      expect { click_link "Skip" }.to \
        send_email.to(ENV['MAILPARSER_SURVEY_COMPLETE'])
        .with_subject("App Profile Complete - #{account.email}")
    end
  end
end
