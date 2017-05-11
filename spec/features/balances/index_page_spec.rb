require 'rails_helper'

RSpec.describe 'balance index page' do
  include AwardWalletMacros

  include_context 'logged in'
  let(:owner) { account.owner }

  before(:all) { @currencies = Array.new(2) { create_currency } }
  let(:currencies) { @currencies }

  def create_balance(currency, value)
    super(value: value, person: owner, currency: currency)
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

  example 'deleting a balance', :js do
    balance = create_balance(currencies[0], 1234)
    visit balances_path

    within_balance(balance) do
      click_link 'Delete'
    end
    expect(page).not_to have_content currencies[0].name
    expect(Balance.exists?(id: balance.id)).to be false
  end

  example "when I've linked my account to AwardWallet" do
    setup_award_wallet_user_from_sample_data(account)
    visit balances_path
    account.award_wallet_accounts.each do |awa|
      section = awa.person.nil? ? '#unassigned_balances' : '#owner_balances'
      within section do
        expect(page).to have_selector "#award_wallet_account_#{awa.id}"
      end
    end
  end

  def within_balance(balance, &block)
    within("#balance_#{balance.id}", &block)
  end
end
