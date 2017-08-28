require 'rails_helper'

RSpec.describe 'edit account page' do
  let(:current_pw) { 'abroaders123' }
  let(:account) do
    create_account(
      :onboarded,
      password: current_pw,
      password_confirmation: current_pw,
      phone_number: '+1 (555) 345-1234',
    )
  end

  before do
    login_as_account(account)
    visit edit_account_path
  end

  let(:submit_form) { click_button 'Save Account Settings' }

  example 'success' do
    fill_in :account_email, with: 'mynewemail@example.com'
    fill_in :account_password, with: 'new_password'
    fill_in :account_password_confirmation, with: 'new_password'
    fill_in :account_current_password, with: current_pw
    fill_in :account_phone_number, with: '(985) 563-7565'
    submit_form

    expect(page).to have_success_message
    account.reload

    expect(account.email).to eq 'mynewemail@example.com'
    expect(account.valid_password?('new_password')).to be true
    expect(account.phone_number).to eq '(985) 563-7565'
    expect(account.phone_number_normalized).to eq '9855637565'
    expect(account.phone_number_us_normalized).to eq '19855637565'

    # still signed in after changing password - this is a bug fix:
    visit root_path
    expect(page).to have_selector '#sign_out_link'
    expect(current_path).not_to eq new_account_session_path
  end

  example 'removing phone number' do
    fill_in :account_phone_number, with: '  '
    submit_form

    expect(page).to have_success_message
    account.reload

    expect(account.phone_number).to be_nil
    expect(account.phone_number_normalized).to be_nil
    expect(account.phone_number_us_normalized).to be_nil
  end

  example 'failure - incorrect current password' do
    fill_in :account_email, with: 'mynewemail@example.com'
    fill_in :account_password, with: 'new_password'
    fill_in :account_password_confirmation, with: 'new_password'
    fill_in :account_current_password, with: 'wrong!'

    expect do
      submit_form
      account.reload
    end.not_to change { account.email }

    expect(page).to have_error_message
    expect(account.valid_password?('abroaders123')).to be true
  end

  example 'updating only email address doesnt require current pw' do
    fill_in :account_email, with: 'mynewemail@example.com'
    click_button 'Save'

    expect(page).to have_success_message
    account.reload

    expect(account.email).to eq 'mynewemail@example.com'
    expect(account.valid_password?('abroaders123')).to be true
  end
end
