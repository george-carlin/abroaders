require 'rails_helper'

RSpec.describe AdminArea::CardRecommendations::Update do
  let(:op) { described_class }

  let(:person)  { create_account(:onboarded).owner }
  let(:product) { create(:card_product) }

  let(:dec_2015) { Date.new(2015, 12) }
  let(:jan_2016) { Date.new(2016, 1) }

  let(:params) { { card: {} } }

  # Use the same person and product every time for DRYness.
  def create_rec(options = {})
    super(options.merge(person: person, card_product: product))
  end

  example 'updating' do
    rec = create_rec
    params[:card] = { applied_on: dec_2015, opened_on: jan_2016 }
    params[:id] = rec.id

    result = op.(params)
    expect(result.success?).to be true

    rec = result['model']
    expect(rec.applied_on.to_date).to eq dec_2015
    expect(rec.opened_on.to_date).to eq jan_2016
  end
end
