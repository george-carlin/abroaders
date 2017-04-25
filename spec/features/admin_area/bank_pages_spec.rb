require 'rails_helper'

RSpec.describe 'admin - bank pages' do
  include_context 'logged in as admin'

  describe 'index page' do
    let(:banks) { Bank.all }
    before { visit admin_banks_path }

    it 'lists banks' do
      banks.each do |bank|
        expect(page).to have_content bank.name
        expect(page).to have_content bank.personal_phone unless bank.personal_phone.nil?
        expect(page).to have_content bank.business_phone unless bank.business_phone.nil?
      end
    end
  end
end
