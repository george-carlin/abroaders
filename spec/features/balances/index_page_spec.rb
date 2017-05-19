require 'rails_helper'

RSpec.describe 'balance index page' do
  include AwardWalletMacros

  include_context 'logged in'
  let(:owner) { account.owner }

  let(:currencies) { Array.new(2) { create_currency } }

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

  let(:extra_column_headers) { %w[Owner Account Expires] }

  let(:sync_btn_text) { 'Sync Balances' }

  context "when I haven't linked my account to AwardWallet" do
    before do # make sure the account actually has balances or there'll be no table
      create_balance(currencies[0], 1234)
      raise if account.award_wallet? # sanity check
      visit balances_path
    end

    it 'clicking "Add new"' do
      click_link 'Add new'
      expect(current_path).to eq new_person_balance_path(owner)
    end

    it 'hides the unnecessary columns in the table' do
      extra_column_headers.each do |text|
        expect(page).to have_no_selector 'th', text: text
      end
    end

    it 'has no "Sync balances" button' do
      expect(page).to have_no_button sync_btn_text
    end
  end

  context "when I've linked my account to AwardWallet" do
    before do
      setup_award_wallet_user_from_sample_data(account)
      visit balances_path
    end

    it 'lists my award wallet accounts' do
      account.award_wallet_accounts.each do |awa|
        section = awa.person.nil? ? '#unassigned_balances' : '#owner_balances'
        within section do
          expect(page).to have_selector "#award_wallet_account_#{awa.id}"
        end
      end
    end

    it 'clicking "Add new"', :js do
      click_button 'Add new'
      expect(page).to have_link 'Add a new balance on Abroaders', href: new_person_balance_path(owner)
      expect(page).to have_link 'Add a new balance on AwardWallet', href: 'https://awardwallet.com/account/select-provider'
    end

    it 'has extra columns in the table' do
      extra_column_headers.each do |text|
        expect(page).to have_selector 'th', text: text
      end
    end

    example 'syncing my balances', :js do
      click_button sync_btn_text

      expect(page).to have_link 'Import Balances', href: integrations_award_wallet_sync_path
      expect(page).to have_link 'Update Balances', href: 'https://awardwallet.com/account/list'
    end
  end

  def within_balance(balance, &block)
    within("#balance_#{balance.id}", &block)
  end
end
