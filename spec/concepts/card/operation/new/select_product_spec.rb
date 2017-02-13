require 'rails_helper'

RSpec.describe Card::Operation::New::SelectProduct do
  let(:person)  { create(:account).owner }
  let(:product) { create(:card_product) }
  let(:op) { described_class }

  let(:result) { op.() }

  it 'is always successful' do
    expect(result.success?).to be true
  end

  specify '"collection" key contains products' do
    # returns all products, including those not shown on the survey
    products = create_list(:card_product, 3).tap { |p| p[-1].update!(shown_on_survey: false) }
    expect(result['collection']).to eq products
  end

  specify '"banks" key contains banks ordered by name' do
    b = Bank.create!(name: 'B', personal_code: 0)
    a = Bank.create!(name: 'A', personal_code: 0)
    c = Bank.create!(name: 'C', personal_code: 0)
    expect(result['banks']).to eq [a, b, c]
  end
end
