require 'rails_helper'

module AdminArea
  describe Card::Operations::Update do
    let(:bank)    { create(:bank, name: "Chase") }
    let(:person)  { create(:account, :onboarded).owner }
    let(:product) { create(:card_product) }

    let(:nov_2015) { Date.new(2015, 11) }
    let(:dec_2015) { Date.new(2015, 12) }
    let(:jan_2016) { Date.new(2016, 1) }

    let(:params) { { card: {} } }

    example 'updating opened_at date' do
      card = ::Card.create!(person: person, product: product, opened_at: dec_2015)
      params[:card] = { opened_at: jan_2016 }
      params[:id]   = card.id
      result = described_class.(params)
      expect(result.success?).to be true

      card = result['model']
      expect(card.closed_at).to be_nil
      expect(card.opened_at).to eq jan_2016
    end

    example 'closing an open card' do
      card = ::Card.create!(person: person, product: product, opened_at: dec_2015)
      params[:card] = { closed: true, closed_at: jan_2016, opened_at: dec_2015 }
      params[:id]   = card.id
      result = described_class.(params)
      expect(result.success?).to be true

      card = result['model']
      expect(card.closed_at).to eq jan_2016
      expect(card.opened_at).to eq dec_2015
    end

    example 'unclosing a closed card' do
      card = ::Card.create!(
        person: person, product: product, opened_at: dec_2015, closed_at: jan_2016,
      )
      params[:card] = { opened_at: dec_2015 }
      params[:id]   = card.id
      result = described_class.(params)
      expect(result.success?).to be true

      card = result['model']
      expect(card.closed_at).to be nil
      expect(card.opened_at).to eq dec_2015
    end

    example 'invalid save' do
      card = ::Card.create!(person: person, product: product, opened_at: dec_2015)
      # closed before opened:
      params[:card] = { opened_at: dec_2015, closed_at: nov_2015, closed: true }
      params[:id]   = card.id
      result = described_class.(params)
      expect(result.success?).to be false
    end
  end
end
