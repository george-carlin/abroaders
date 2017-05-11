require 'cells_helper'

RSpec.describe Balance::Cell::Index do
  controller BalancesController

  let(:account) { create(:account) }
  let(:owner) { account.owner }

  let(:current_account) { account }

  it 'asks me to connect to AwardWallet' do
    rendered = cell(account).()
    expect(rendered).to have_content 'Connect your AwardWallet account to Abroaders'
    expect(rendered).to have_link 'Connect to AwardWallet'
    expect(rendered).to have_no_content "You're connected to your AwardWallet account"
    expect(rendered).to have_no_link 'Manage settings'
  end

  context 'when account is connected to AwardWallet' do
    before do
      account.build_award_wallet_user(loaded: true, user_name: 'AWUser')
    end

    it 'has link to AW settings page' do
      rendered = cell(account).()
      expect(rendered).to have_content "You're connected to your AwardWallet account"
      expect(rendered).to have_content 'AWUser'
      expect(rendered).to have_link 'Manage settings', href: integrations_award_wallet_settings_path
      expect(rendered).to have_no_content 'Connect your AwardWallet account to Abroaders'
      expect(rendered).to have_no_link 'Connect to AwardWallet'
    end
  end

  example 'solo account with no balances' do
    rendered = cell(account).()
    expect(rendered).to have_selector 'h1', text: 'My points'
    expect(rendered).to have_content 'No points balances'
  end

  example 'solo account with balances' do
    balances = Array.new(2) { create_balance(person: owner) }

    rendered = cell(account).()
    expect(rendered).to have_selector 'h1', text: 'My points'
    expect(rendered).not_to have_content 'No points balances'
    expect(rendered).to have_content balances[0].currency_name
    expect(rendered).to have_content balances[1].currency_name
  end

  describe 'couples account' do
    let!(:companion) { account.create_companion!(first_name: 'Gabi') }

    example 'neither person has balances' do
      rendered = cell(account).()
      expect(rendered).to have_selector 'h1', text: "Erik's points"
      expect(rendered).to have_selector 'h1', text: "Gabi's points"
      expect(rendered).to have_content 'No points balances', count: 2
    end

    example 'one person has no balances' do
      create_balance(person: owner)
      rendered = cell(account).()
      expect(rendered).to have_selector 'h1', text: "Erik's points"
      expect(rendered).to have_selector 'h1', text: "Gabi's points"
      expect(rendered).to have_content owner.balances[0].currency_name
      expect(rendered).to have_content 'No points balances', count: 1
    end

    example 'both people have balances' do
      ob = create_balance(person: owner)
      cb = create_balance(person: companion)

      rendered = cell(account).()
      expect(rendered).to have_selector 'h1', text: "Erik's points"
      expect(rendered).to have_selector 'h1', text: "Gabi's points"
      expect(rendered).to have_content ob.currency_name
      expect(rendered).to have_content cb.currency_name
      expect(rendered).to have_no_content 'No points balances'
    end
  end

  it 'avoids XSS' do
    owner.update!(first_name: '<script>')
    account.create_companion!(first_name: '</script>')
    rendered = raw_cell(account)
    expect(rendered).to include "&lt;script&gt;"
    expect(rendered).to include "&lt;/script&gt;"
  end
end
