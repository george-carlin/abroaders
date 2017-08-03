require 'rails_helper'

RSpec.describe 'edit admin page' do
  include_context 'logged in as admin'

  let(:other_admin) { create_admin }

  before { visit edit_admin_admin_path(other_admin) }

  example 'admin edit another admin' do
    fill_in :admin_email, with: 'newaddress@abroaders.com'
    fill_in :admin_name, with: 'Bob'

    click_button 'Save'

    other_admin.reload
    expect(other_admin.email).to eq 'newaddress@abroaders.com'
    expect(other_admin.name).to eq 'Bob'

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
    expect(page).to have_field :admin_name
  end
end
