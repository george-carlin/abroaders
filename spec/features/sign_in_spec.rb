require 'rails_helper'

RSpec.describe 'the sign in page' do
  let(:password) { 'foobar123' }
  let(:email)    { 'example@example.com' }

  before do
    run!(
      Registration::Operation::Create,
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

  example 'invalid sign in' do
    submit_form
    expect(page).to have_content 'Sign in'
    expect(page).to have_no_selector '#sign_out_link'
    expect(page).to have_no_content email
  end
end
