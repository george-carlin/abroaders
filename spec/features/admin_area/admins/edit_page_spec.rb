require 'rails_helper'

RSpec.describe 'edit admin page' do
  include_context 'logged in as admin'

  let(:image_path) { Rails.root.join('spec', 'support', 'erik.png') }
  let(:other_admin) { create_admin }

  before { visit edit_admin_admin_path(other_admin) }

  example 'admin edit another admin' do
    fill_in :admin_email, with: 'newaddress@abroaders.com'
    fill_in :admin_first_name, with: 'Bob'
    fill_in :admin_last_name, with: 'Smith'
    attach_file :admin_avatar, image_path

    click_button 'Save'

    other_admin.reload
    expect(other_admin.email).to eq 'newaddress@abroaders.com'
    expect(other_admin.full_name).to eq 'Bob Smith'

    expect(current_path).to eq admin_admins_path
    expect(page).to have_content 'newaddress@abroaders.com'
  end

  example 'admin tries to create invalid admin' do
    fill_in :admin_email, with: ''
    expect do
      click_button 'Save'
      other_admin.reload
    end.not_to change { other_admin.email }

    # still shows form:
    expect(page).to have_field :admin_email
    expect(page).to have_field :admin_first_name
  end
end
