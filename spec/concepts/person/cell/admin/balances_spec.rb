require 'rails_helper'

RSpec.describe Person::Cell::Admin::Balances, type: :view do
  let(:person) { create(:person) }
  include ActionView::Helpers::NumberHelper

  subject(:cell) { described_class.(person).show }

  example 'when the person has no balances' do
    expect(cell).not_to have_selector 'h3', text: 'Existing Balances'
    expect(cell).to have_content 'User does not have any existing points/miles balances'
  end

  context 'when the person has balances' do
    let!(:balances) { create_list(:balance, 2, person: person) }

    it 'lists them' do
      expect(cell).to have_selector 'h3', text: 'Existing Balances'
      balances.each do |balance|
        expect(cell).to have_content balance.currency.name
        expect(cell).to have_content number_with_delimiter(balance.value)
      end
    end
  end
end
