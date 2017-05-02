require 'rails_helper'

RSpec.describe 'balance index page' do
  include AwardWalletMacros

  include_context 'logged in'
  let(:owner) { account.owner }

  before(:all) { @currencies = create_list(:currency, 2) }
  let(:currencies) { @currencies }

  def create_balance(currency, value)
    run!(
      Balance::Create,
      {
        balance: { currency_id: currency.id, value: value },
        person_id: owner.id,
      },
      'account' => account,
    )['model']
  end

  example "viewing my balances" do
    balance_0 = create_balance(currencies[0], 1234)
    balance_1 = create_balance(currencies[1], 2468)
    visit balances_path

    within_balance(balance_0) do
      expect(page).to have_content "1,234"
      expect(page).to have_content currencies[0].name
    end

    within_balance(balance_1) do
      expect(page).to have_content "2,468"
      expect(page).to have_content currencies[1].name
    end
  end

  example "updating a balance", :js, :manual_clean do
    balance = create_balance(currencies[0], 1234)
    visit balances_path
    update_balance_value(balance, 2345)
    balance.reload
    expect(balance.value).to eq 2345
  end

  example "trying to update a balance invalidly", :js, :manual_clean do
    balance = create_balance(currencies[0], 1234)
    visit balances_path

    expect do
      update_balance_value(balance, -2345)
      balance.reload
    end.not_to change { balance.value }

    expect(page).to have_content "Invalid value"
  end

  example 'deleting a balance', :js do
    balance = create_balance(currencies[0], 1234)
    visit balances_path

    within_balance(balance) do
      click_link 'Delete'
    end
    expect(page).not_to have_content currencies[0].name
    expect(Balance.exists?(id: balance.id)).to be false
  end

  skip "when I've linked my account to AwardWallet" do
    setup_award_wallet_user_from_sample_data(account)
    visit balances_path
    # it shows my award wallet balances
  end

  def balance_selector(balance)
    "#balance_#{balance.id}"
  end

  def within_balance(balance, &block)
    within(balance_selector(balance), &block)
  end

  def update_balance_value(balance, new_value)
    within_balance(balance) do
      click_button 'Edit'
      fill_in :balance_value, with: new_value
      click_button 'Save'
      wait_for_ajax
    end
  end
end
