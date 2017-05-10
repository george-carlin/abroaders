require 'rails_helper'

RSpec.describe 'new balance pages' do
  include_context 'logged in'

  before(:all) { @currencies = Array.new(2) { create_currency } }
  let(:currencies) { @currencies }

  describe 'new page' do
    before { visit new_person_balance_path(owner) }

    example 'page layout and form' do
      expect(page).to have_field :balance_currency_id
      expect(page).to have_field :balance_value
      expect(page).to have_button 'Save'
    end

    example 'creating a new balance' do
      select currencies[1].name, from: :balance_currency_id
      fill_in :balance_value, with: 2345

      # it creates a balance:
      expect do
        click_button 'Save'
      end.to change { owner.balances.count }.by(1)

      # it has the right values:
      balance = owner.balances.last
      expect(balance.currency).to eq currencies[1]
      expect(balance.value).to eq 23_45
    end

    example 'submitting a balance without a value' do
      select currencies[1].name, from: :balance_currency_id
      # it doesn't create a balance:
      expect { click_button 'Save' }.not_to change { owner.balances.count }
      expect(page).to have_error_message
    end

    example 'submitting a balance with a negative value' do
      fill_in :balance_value, with: -1

      expect do
        click_button 'Save'
      end.not_to change { owner.balances.count }

      expect(page).to have_field :balance_value, with: -1 # bug fix
    end

    # TODO what happens if I submit letters?
  end
end
