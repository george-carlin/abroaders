require 'cells_helper'

RSpec.describe Balance::Cell::Index do
  controller BalancesController

  let(:currencies) { Array.new(2) { |i| Currency.new(name: "Curr #{i}") } }

  let(:account) { Account.new }
  let(:owner) { account.build_owner(id: 1, first_name: 'Erik') }

  def get_result(data)
    Trailblazer::Operation::Result.new(true, data)
  end

  example 'solo account with no balances' do
    result = get_result(
      'account' => account,
      'people'  => [owner],
      'balances' => [],
    )
    rendered = show(result)
    expect(rendered).to have_selector 'h1', text: 'My points'
    expect(rendered).to have_content 'No balances'
  end

  example 'solo account with balances' do
    balances = Array.new(2) do |i|
      owner.balances.build(id: i, value: 1234, currency: currencies[i], updated_at: 5.minutes.ago)
    end

    result = get_result(
      'account'  => account,
      'people'   => [owner],
      'balances' => balances,
    )

    rendered = show(result)
    expect(rendered).to have_selector 'h1', text: 'My points'
    expect(rendered).not_to have_content 'No balances'
    expect(rendered).to have_content 'Curr 0'
    expect(rendered).to have_content 'Curr 1'
  end

  describe 'couples account' do
    let!(:companion) { account.build_companion(id: 2, first_name: 'Gabi') }

    let!(:owner_balances) do
      Array.new(2) do |i|
        owner.balances.build(id: i, value: 1234, currency: currencies[i], updated_at: 5.minutes.ago)
      end
    end

    it '' do
      companion_balances = Array.new(2) do |i|
        companion.balances.build(id: i, value: 1234, currency: currencies[i], updated_at: 5.minutes.ago)
      end

      result = get_result(
        'account' => account,
        'people' => [owner, companion],
        'balances' => [*owner_balances, *companion_balances],
      )

      rendered = show(result)
      expect(rendered).not_to have_content 'My points'
      expect(rendered).not_to have_content 'No balances'
      expect(rendered).to have_selector 'h1', text: "Erik's points"
      expect(rendered).to have_selector 'h1', text: "Gabi's points"
    end

    example 'where one person has no balances' do
      result = get_result(
        'account' => account,
        'people' => [owner, companion],
        'balances' => owner_balances,
      )

      rendered = show(result)
      expect(rendered).to have_selector 'h1', text: "Erik's points"
      expect(rendered).to have_selector 'h1', text: "Gabi's points"
    end
  end
end
