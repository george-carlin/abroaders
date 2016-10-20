require "rails_helper"

describe "phone number pages" do
  let!(:account) { create(:account, onboarding_state: :phone_number) }
  before do
    login_as_account(account)
    visit new_phone_number_path
  end

  include_context "set admin email ENV var"

  let(:submit_form) { click_button "Save and continue" }

  describe "new page" do
    example "submitting a phone number" do
      fill_in :account_phone_number, with: "555 000-1234"
      submit_form
      account.reload
      expect(account.phone_number).to eq "555 000-1234"
      expect(account.onboarding_state).to eq "complete"
      expect(current_path).to eq root_path
    end

    example "notifying the admin that the survey is complete" do
      fill_in :account_phone_number, with: "555 000-1234"
      expect { submit_form }.to \
        send_email.to(ENV["ADMIN_EMAIL"])
        .with_subject("App Profile Complete - #{account.email}")
    end

    example "submitting a phone number with trailing whitespace" do
      fill_in :account_phone_number, with: "     555 000-1234    "
      submit_form
      account.reload
      expect(account.phone_number).to eq "555 000-1234"
      expect(account.onboarding_state).to eq "complete"
      expect(current_path).to eq root_path
    end

    example "submitting with no phone number" do
      submit_form
      account.reload
      expect(account.phone_number).to be_nil
      expect(page).to have_error_message
    end

    example "submitting a whitespace-only phone number" do
      fill_in :account_phone_number, with: "       "
      submit_form
      account.reload
      expect(account.phone_number).to be_nil
      expect(page).to have_error_message
    end

    example "skipping the form" do
      expect { click_link "Skip" }.to \
        send_email.to(ENV["ADMIN_EMAIL"])
        .with_subject("App Profile Complete - #{account.email}")
    end
  end
end
