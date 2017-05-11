require 'cells_helper'

RSpec.describe AdminArea::People::Cell::Balances do
  controller AdminArea::PeopleController

  let(:person) { Person.new(id: 123, first_name: 'Erik') }
  include ActionView::Helpers::NumberHelper

  let(:rendered) { cell(person).() }

  example 'when the person has no balances' do
    expect(rendered).not_to have_selector 'h3', text: 'Existing Balances'
    expect(rendered).to have_content 'User does not have any existing points/miles balances'
  end

  context 'when the person has balances' do
    let(:currencies) { Array.new(2) { |i| Currency.new(name: "Curr #{i}") } }
    let(:balances) do
      [
        person.balances.build(currency: currencies[0], value: 1234),
        person.balances.build(currency: currencies[1], value: 4321),
      ]
    end

    before { allow(person).to receive(:balances).and_return(balances) }

    it 'lists them' do
      expect(rendered).to have_selector 'h3', text: 'Existing Balances'
      balances.each do |balance|
        expect(rendered).to have_content balance.currency.name
        expect(rendered).to have_content number_with_delimiter(balance.value)
      end
    end
  end
end
