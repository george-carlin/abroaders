require 'rails_helper'

RSpec.describe 'admin currency pages' do
  include_context 'logged in as admin'

  example 'index page' do
    currencies = Array.new(2) { create_currency }
    visit admin_currencies_path

    currencies.each do |currency|
      expect(page).to have_content currency.name
    end
  end

  describe 'new page' do
    before { visit new_admin_currency_path }

    example 'success' do
      fill_in :currency_name, with: '   Example currency   ' # strip whitespace
      select 'bank', from: :currency_type
      select 'SkyTeam', from: :currency_alliance_name

      expect do
        click_button 'Save'
      end.to change { Currency.count }.by(1)

      curr = Currency.last
      expect(curr.name).to eq 'Example currency'
      expect(curr.type).to eq 'bank'
      expect(curr.alliance_name).to eq 'SkyTeam'

      expect(current_path).to eq admin_currencies_path
    end

    example 'failure' do
      expect { click_button 'Save' }.not_to change { Currency.count }

      expect(page).to have_field :currency_name
    end
  end

  describe 'edit page' do
    let(:currency) { create_currency }
    before { visit edit_admin_currency_path(currency) }

    example 'success' do
      fill_in :currency_name, with: '   New name   ' # strip whitespace
      select 'bank', from: :currency_type
      select 'SkyTeam', from: :currency_alliance_name

      click_button 'Save'
      currency.reload

      expect(currency.name).to eq 'New name'
      expect(currency.type).to eq 'bank'
      expect(currency.alliance_name).to eq 'SkyTeam'

      expect(current_path).to eq admin_currencies_path
    end

    example 'failure' do
      fill_in :currency_name, with: ''
      expect do
        click_button 'Save'
        currency.reload
      end.not_to change { currency.name }

      expect(page).to have_field :currency_name
    end
  end
end
