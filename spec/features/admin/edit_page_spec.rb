require 'rails_helper'

RSpec.describe 'admin - edit page' do
  let(:pw) { 'abroaders123' }
  let(:admin) { create_admin(password: pw, password_confirmation: pw) }

  before do
    login_as_admin(admin)
    visit edit_admin_registration_path
  end

  def submit_form
    click_button 'Update'
    admin.reload
  end

  example 'updating password' do
    new_pw = 'new_password'
    fill_in :admin_password, with: new_pw
    fill_in :admin_password_confirmation, with: new_pw
    fill_in :admin_current_password, with: pw

    expect { submit_form }.to change { admin.encrypted_password }

    expect(page).to have_content 'Your account has been updated successfully'

    find('#sign_out_link').click

    visit new_admin_session_path

    fill_in :admin_email, with: admin.email
    fill_in :admin_password, with: new_pw
    click_button 'Sign in'
    expect(page).to have_content 'Signed in successfully'
  end

  example "invalid update - passwords don't match" do
    new_pw = 'new_password'
    fill_in :admin_password, with: new_pw
    fill_in :admin_password_confirmation, with: 'whoops!'
    fill_in :admin_current_password, with: 'abroaders123'

    expect { submit_form }.not_to change { admin.encrypted_password }

    expect(page).to have_field :admin_password
    expect(page).to have_field :admin_password_confirmation
    expect(page).to have_field :admin_current_password
  end

  example 'invalid update - incorrect current password' do
    new_pw = 'new_password'
    fill_in :admin_password, with: new_pw
    fill_in :admin_password_confirmation, with: new_pw
    fill_in :admin_current_password, with: 'incorrect'

    expect { submit_form }.not_to change { admin.encrypted_password }

    expect(page).to have_field :admin_password
    expect(page).to have_field :admin_password_confirmation
    expect(page).to have_field :admin_current_password
  end
end
