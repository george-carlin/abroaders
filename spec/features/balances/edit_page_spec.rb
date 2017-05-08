require 'rails_helper'

RSpec.describe 'balance edit page' do
  include_context 'logged in'

  let(:owner) { account.owner }

  let(:balance) { create_balance(person: owner, value: 33333) }

  before do
    visit edit_balance_path(balance)
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
end
