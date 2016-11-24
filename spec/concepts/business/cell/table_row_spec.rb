require 'rails_helper'

RSpec.describe Business::Cell::TableRow, type: :view do
  let(:attributes) do
    Struct.new(:spending_usd, :ein).new(1234, ein)
  end

  subject(:cell) { described_class.(attributes).show }

  context 'when there is no business' do
    let(:cell) { described_class.(nil).show }
    it 'says "No business"' do
      expect(cell).to have_content 'No business'
      expect(cell).not_to have_selector '.has-ein'
      expect(cell).not_to have_selector '.spending-info-business-spending'
    end
  end

  context 'when there is a business with EIN' do
    let(:ein) { true }
    it 'displays the business information' do
      expect(cell).not_to have_content 'No business'
      expect(cell).to have_selector '.has-ein', text: 'Has EIN'
      expect(cell).to have_selector '.spending-info-business-spending', text: '$1,234.00'
    end
  end

  context 'when the person has a business with no EIN' do
    let(:ein) { false }
    it 'displays the business information' do
      expect(cell).not_to have_content 'No business'
      expect(cell).to have_selector '.has-ein', text: 'Does not have EIN'
      expect(cell).to have_selector '.spending-info-business-spending', text: '$1,234.00'
    end
  end
end
