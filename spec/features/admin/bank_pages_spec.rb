require 'rails_helper'

module AdminArea
  RSpec.describe 'bank pages' do
    include_context 'logged in as admin'

    describe 'index page' do
      before do
        @banks = create_list(:bank, 2)
        visit admin_banks_path
      end

      it 'lists banks' do
        @banks.each do |bank|
          expect(page).to have_content bank.name
          expect(page).to have_content bank.personal_phone
          expect(page).to have_content bank.business_phone
          expect(page).to have_link 'Edit', href: edit_admin_bank_path(bank)
        end
      end
    end

    describe 'edit page' do
      before do
        @bank = create(:bank)
        visit edit_admin_bank_path(@bank)
      end

      example 'valid update' do
        fill_in :bank_name, with: 'Bankeroo'
        fill_in :bank_personal_phone, with: '12341234'
        fill_in :bank_business_phone, with: '43214321'
        click_button 'Save'
        @bank.reload
        expect(@bank.name).to eq 'Bankeroo'
        expect(@bank.personal_phone).to eq '12341234'
        expect(@bank.business_phone).to eq '43214321'
        expect(current_path).to eq admin_banks_path
      end

      example 'invalid update' do
        fill_in :bank_name, with: ''
        expect do
          click_button 'Save'
        end.not_to change { @bank.reload.name }
        expect(page).to have_field :bank_name
      end
    end
  end
end
