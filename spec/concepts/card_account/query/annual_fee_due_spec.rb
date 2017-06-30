require 'rails_helper'

RSpec.describe CardAccount::Query::AnnualFeeDue do
  # This query should only ever be run on the first day of the month
  before { Timecop.freeze(Date.new(2017, 5, 1)) }
  after { Timecop.return }

  let(:person) { create_account.owner }
  let(:card_product) { create(:card_product) }

  let(:query) { described_class }

  # use the same person and product every time to save DB queries
  def create_card_account(overrides = {})
    overrides[:card_product] = card_product
    overrides[:person] = person
    super(overrides)
  end

  it 'returns all card accounts with an annual fee due this month' do
    due = [
      create_card_account(opened_on: Date.new(2016, 5, 1)),
      create_card_account(opened_on: Date.new(2016, 5, 31)),
      create_card_account(opened_on: Date.new(2016, 5, 15)),
      create_card_account(opened_on: Date.new(2015, 5, 15)),
      create_card_account(opened_on: Date.new(2015, 5, 15)),
    ]

    _not_due = [
      create_card_account(opened_on: Date.new(2017, 5, 1)),
      create_card_account(opened_on: Date.new(2017, 4, 30)),
      create_card_account(opened_on: Date.new(2016, 4, 30)),
      create_card_account(opened_on: Date.new(2016, 6, 1)),
      create_card_account(opened_on: Date.new(2016, 5, 3), closed_on: Date.new(2016, 5, 5)),
    ]

    expect(query.()).to match_array(due)
  end
end
