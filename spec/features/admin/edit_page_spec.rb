require 'rails_helper'

RSpec.describe 'admin - edit page' do
  include_context 'logged in as admin'

  before { visit edit_admin_registration_path }

  example 'updating password' do
    new_pw = 'new_password'
    fill_in :admin_password, with: new_pw
    fill_in :admin_password_confirmation, with: new_pw
    fill_in :admin_current_password, with: 'abroaders123'

    expect do
      click_button 'Update'
      admin.reload
    end.to change { admin.encrypted_password }

    expect(page).to have_content 'Your account has been updated successfully'

    find('#sign_out_link').click

    visit new_admin_session_path

    fill_in :admin_email, with: admin.email
    fill_in :admin_password, with: new_pw
    click_button 'Sign in'
    expect(page).to have_content 'Signed in successfully'
  end
end
