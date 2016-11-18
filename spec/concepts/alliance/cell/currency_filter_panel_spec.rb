require 'rails_helper'

RSpec.describe Alliance::Cell::CurrencyFilterPanel, type: :view do
  let(:alliance)   { Alliance.create(id: 1, name: 'My Alliance') }
  let(:currencies) { Array.new(alliance.currencies.airline) { |c| c.build(name: "Currency #{i}") } }
  let(:hotel_currency) { alliance.currencies.hotel.build(name: 'Bank') }
  let(:bank_currency)  { alliance.currencies.bank.build(name: 'Hotel') }

  let(:other_alliance) { Alliance.new(name: 'Other Alliance') }
  let(:other_currency) { other_alliance.currencies.build(name: 'Nope') }

  subject(:cell) { described_class.(alliance).to_s }

  # this is already covered by the features spec but could be extracted to here
  skip { is_expected.to have_field :card_currency_alliance_filter_all_for_1 }
  skip 'has a checkbox for each filterable currency in this alliance'
end
