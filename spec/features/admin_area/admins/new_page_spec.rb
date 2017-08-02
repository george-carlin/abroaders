require 'rails_helper'

RSpec.describe 'new admin page' do
  include_context 'logged in as admin'

  before { visit new_admin_admin_path }

  example 'admin adds another admin' do
    fill_in :admin_email, with: 'newadmin@abroaders.com'
    fill_in :admin_name, with: 'Bob'
    fill_in :admin_password, with: 'password123'

    expect do
      click_button 'Save'
    end.to change { Admin.count }.by(1)

    admin = Admin.last
    expect(admin.email).to eq 'newadmin@abroaders.com'
    expect(admin.name).to eq 'Bob'
    expect(admin.valid_password?('password123')).to be true

    expect(current_path).to eq admin_admins_path
    expect(page).to have_content 'newadmin@abroaders.com'
  end

  example 'admin tries to create invalid admin' do
    expect do
      click_button 'Save'
    end.not_to change { Admin.count }

    # still shows form:
    expect(page).to have_field :admin_email
    expect(page).to have_field :admin_name
    expect(page).to have_field :admin_password
  end
end
