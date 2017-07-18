require 'rails_helper'

RSpec.describe 'the sign in page', :auth do
  let(:password) { 'foobar123' }
  let(:email)    { 'example@example.com' }

  before do
    run!(
      Registration::Create,
      account: {
        email: email,
        first_name: 'George',
        password: password,
        password_confirmation: password,
      },
    )['model']
    visit new_account_session_path
  end

  let(:submit_form) { click_button 'Sign in' }

  example 'signing in', :js do
    fill_in :account_email,    with: email
    fill_in :account_password, with: password
    submit_form
    expect(page).to have_selector '#sign_out_link'
    expect(page).to have_content email
    expect(page).to have_no_content 'Sign in'
    expect(current_path).to eq survey_home_airports_path # first onboarding page
  end

  example 'signing out' do
    fill_in :account_email,    with: email
    fill_in :account_password, with: password
    submit_form

    find('#sign_out_link').click

    expect(page).to have_no_selector '#sign_out_link'
    expect(page).to have_no_content email
    expect(page).to have_content 'Sign in'
  end

  example 'invalid sign in' do
    submit_form
    expect(page).to have_content 'Sign in'
    expect(page).to have_no_selector '#sign_out_link'
    expect(page).to have_no_content email
  end

  example "can't visit page when already signed in" do
    fill_in :account_email,    with: email
    fill_in :account_password, with: password
    submit_form

    visit new_account_session_path
    expect(page).to have_content 'You are already signed in'
    expect(current_path).not_to eq new_account_session_path

    visit new_admin_session_path
    expect(page).to have_content 'You must sign out'
    expect(current_path).not_to eq new_admin_session_path
  end

  example 'remember my location' do
    path = balances_path

    visit path # will redirect to sign in page
    fill_in :account_email,    with: email
    fill_in :account_password, with: password
    submit_form

    expect(path).to eq path # it remembers where I was trying to go
  end
end
