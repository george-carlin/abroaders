require 'rails_helper'

RSpec.describe 'balance edit page' do
  let(:account) { create_account(:onboarded) }
  let(:owner) { account.owner }
  let(:balance) { create_balance(person: owner, value: 33333) }

  before do
    login_as(account)
    visit edit_balance_path(balance)
  end

  example 'page layout and form' do
    expect(page).to have_field :balance_currency_id
    expect(page).to have_no_field :balance_person_id
    expect(page).to have_field :balance_value
    expect(page).to have_button 'Save'
  end

  example 'valid update' do
    fill_in :balance_value, with: 12345
    click_button 'Save'
    expect(balance.reload.value).to eq 12345
    expect(current_path).to eq balances_path
  end

  example 'invalid update' do
    fill_in :balance_value, with: -1
    expect do
      click_button 'Save'
      balance.reload
    end.not_to change { balance.value }

    expect(page).to have_error_message
    expect(page).to have_field :balance_value
  end

  describe 'couples account' do
    let(:account) { create_account(:account, :couples, :onboarded) }
    let(:companion) { account.companion }

    example 'page layout and form' do
      expect(page).to have_field :balance_currency_id
      expect(page).to have_field :balance_person_id
      expect(page).to have_field :balance_value
      expect(page).to have_button 'Save'
    end
  end
end
