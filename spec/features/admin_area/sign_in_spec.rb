require 'rails_helper'

RSpec.describe 'the admin sign in page', :auth do
  before do
    @pw    = "foobar123"
    @admin = create_admin(password: @pw, password_confirmation: @pw)
    visit new_admin_session_path
  end

  example 'form' do
    expect(page).to have_field :admin_email
    expect(page).to have_field :admin_password
  end

  let(:submit_form) { click_button "Sign in" }

  example 'valid sign-in' do
    fill_in :admin_email,    with: @admin.email
    fill_in :admin_password, with: @pw
    submit_form

    expect(page).to have_selector "#sign_out_link"
    expect(page).to have_content @admin.email
    expect(page).to have_no_content "Sign in"
  end

  example 'invalid sign-in attempt' do
    expect do
      submit_form
    end.not_to change { current_path }
    expect(page).to have_no_selector "#sign_out_link"
    expect(page).to have_no_content @admin.email
  end

  example "can't visit sign-in pages when signed in" do
    fill_in :admin_email,    with: @admin.email
    fill_in :admin_password, with: @pw
    submit_form

    visit new_admin_session_path
    expect(page).to have_content 'You are already signed in'
    expect(current_path).not_to eq new_admin_session_path

    visit new_account_session_path
    expect(page).to have_content 'You must sign out'
    expect(current_path).not_to eq new_account_session_path
  end

  example 'signing out' do
    fill_in :admin_email,    with: @admin.email
    fill_in :admin_password, with: @pw
    submit_form

    find('#sign_out_link').click

    expect(page).to have_no_selector '#sign_out_link'
    expect(page).to have_no_content @admin.email
    expect(current_path).to eq new_account_session_path
  end
end
