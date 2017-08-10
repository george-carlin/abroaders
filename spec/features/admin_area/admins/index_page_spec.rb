require 'rails_helper'

RSpec.describe 'admin index page' do
  example 'lists admins' do
    admins = Array.new(3) { create_admin }
    me = admins.last
    login_as_admin me

    visit admin_admins_path

    admins.each do |admin|
      expect(page).to have_selector 'td', text: admin.email
      expect(page).to have_selector 'td', text: admin.full_name
    end
  end
end
