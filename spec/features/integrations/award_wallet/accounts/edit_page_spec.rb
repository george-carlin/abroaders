require 'rails_helper'

RSpec.describe 'award wallet account edit page' do
  include AwardWalletMacros
  include_context 'logged in'

  let(:owner) { account.owner }

  let(:awa) { account.award_wallet_accounts.last }

  before do
    setup_award_wallet_user_from_sample_data(account)
    visit edit_integrations_award_wallet_account_path(awa)
  end

  example 'valid update' do
    fill_in :award_wallet_account_balance, with: 12345
    click_button 'Save'
    expect(awa.reload.balance).to eq 12345
    expect(current_path).to eq balances_path
  end

  example 'invalid update' do
    fill_in :award_wallet_account_balance, with: -1
    expect do
      click_button 'Save'
      awa.reload
    end.not_to change { awa.balance }

    expect(page).to have_error_message
    expect(page).to have_field :award_wallet_account_balance
  end
end
