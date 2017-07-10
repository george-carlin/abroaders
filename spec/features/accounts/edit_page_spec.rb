require 'rails_helper'

RSpec.describe 'edit account page' do
  let(:current_pw) { 'abroaders123' }
  let(:account) do
    create_account(:onboarded, password: current_pw, password_confirmation: current_pw)
  end

  before do
    login_as_account(account)
    visit edit_account_path
  end

  example 'success' do
    fill_in :account_email, with: 'mynewemail@example.com'
    fill_in :account_password, with: 'new_password'
    fill_in :account_password_confirmation, with: 'new_password'
    fill_in :account_current_password, with: current_pw
    click_button 'Save'

    expect(page).to have_success_message
    account.reload

    expect(account.email).to eq 'mynewemail@example.com'
    expect(account.valid_password?('new_password')).to be true

    # still signed in after changing password - this is a bug fix:
    visit root_path
    expect(page).to have_selector '#sign_out_link'
    expect(current_path).not_to eq new_account_session_path
  end

  example 'failure - incorrect current password' do
    fill_in :account_email, with: 'mynewemail@example.com'
    fill_in :account_password, with: 'new_password'
    fill_in :account_password_confirmation, with: 'new_password'
    fill_in :account_current_password, with: 'wrong!'

    expect do
      click_button 'Save'
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

  describe 'updating phone number' do # TODO
  end

  # TODO - can update person names (remember that person names must be unique
  # per account)
end
