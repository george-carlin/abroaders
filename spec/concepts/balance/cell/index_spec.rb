require 'cells_helper'

# FIXME most of these specs need updating for the refactored cell
RSpec.describe Balance::Cell::Index do
  controller BalancesController

  let(:currencies) { Array.new(2) { |i| Currency.new(name: "Curr #{i}") } }

  let(:account) { Account.new }
  let(:owner) { account.build_owner(id: 1, first_name: 'Erik') }

  example 'solo account with no balances' do
    pending
    rendered = show(account)
    expect(rendered).to have_selector 'h1', text: 'My points'
    expect(rendered).to have_content 'No balances'
  end

  example 'solo account with balances' do
    pending
    2.times do |i|
      owner.balances.build(id: i, value: 1234, currency: currencies[i], updated_at: 5.minutes.ago)
    end

    rendered = show(account)
    pending
    expect(rendered).to have_selector 'h1', text: 'My points'
    expect(rendered).not_to have_content 'No balances'
    expect(rendered).to have_content 'Curr 0'
    expect(rendered).to have_content 'Curr 1'
  end

  example 'account not connected to AwardWallet' do
    rendered = show(account)
    expect(rendered).to have_content 'Connect your AwardWallet account'
    expect(rendered).not_to have_link(
      'Manage settings', href: integrations_award_wallet_settings_path,
    )
  end

  example 'account connected to AwardWallet' do
    account.build_award_wallet_user(loaded: true, user_name: 'AWUser')

    rendered = show(account)
    expect(rendered).not_to have_content 'Connect your AwardWallet account'
    expect(rendered).to have_content 'AWUser'
    expect(rendered).to have_link(
      'Manage settings', href: integrations_award_wallet_settings_path,
    )
  end

  describe 'couples account' do
    let!(:companion) { account.build_companion(id: 2, first_name: 'Gabi') }

    before do
      pending
      2.times do |i|
        owner.balances.build(id: i, value: 1234, currency: currencies[i])
      end
    end

    example 'both people have balances' do
      2.times do |i|
        companion.balances.build(id: i, value: 1234, currency: currencies[i])
      end

      rendered = show(account)
      expect(rendered).not_to have_content 'My points'
      expect(rendered).not_to have_content 'No balances'
      expect(rendered).to have_selector 'h1', text: "Erik's points"
      expect(rendered).to have_selector 'h1', text: "Gabi's points"
    end

    example 'where one person has no balances' do
      rendered = show(account)
      expect(rendered).to have_selector 'h1', text: "Erik's points"
      expect(rendered).to have_selector 'h1', text: "Gabi's points"
    end
  end
end
