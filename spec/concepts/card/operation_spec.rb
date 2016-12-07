require 'rails_helper'

describe Card::Operation do
  let(:bank)    { create(:bank, name: "Chase") }
  let(:account) { create(:account, :onboarded) }
  let(:person)  { account.owner }
  let(:product) { create(:card_product) }

  let(:nov_2015) { Date.new(2015, 11, 30) }
  let(:dec_2015) { Date.new(2015, 12, 31) }
  let(:jan_2016) { Date.new(2016, 0o1, 31) }

  describe Card::Update do
    let(:params) { { current_account: account, person_id: person.id, card: {} } }

    example 'closing an open card' do
      card = Card.create!(person: person, product: product, opened_at: dec_2015)
      params[:card] = { closed: true, closed_at: jan_2016, opened_at: dec_2015 }
      params[:id]   = card.id
      res, op = described_class.run(params)
      expect(res).to be true

      card = op.model
      expect(card.closed_at).to eq jan_2016
      expect(card.opened_at).to eq dec_2015
    end

    example 'unclosing a closed card' do
      card = Card.create!(
        person: person, product: product, opened_at: dec_2015, closed_at: jan_2016,
      )
      params[:card] = { opened_at: dec_2015 }
      params[:id]   = card.id
      res, op = described_class.run(params)
      expect(res).to be true

      card = op.model
      expect(card.closed_at).to be nil
      expect(card.opened_at).to eq dec_2015
    end

    example 'invalid save' do
      card = Card.create!(person: person, product: product, opened_at: dec_2015)
      # closed before opened:
      params[:card] = { opened_at: dec_2015, closed_at: nov_2015, closed: true }
      params[:id]   = card.id
      res, = described_class.run(params)
      expect(res).to be false
    end
  end

  describe Card::Admin::Create do
    example 'creating a card' do
      res, op = described_class.run(
        person_id: person.id,
        card: { product_id: product.id, opened_at:  Date.today },
      )
      expect(res).to be true

      card = op.model
      expect(card.product).to eq product
      expect(card.closed_at).to be nil
      expect(card.opened_at).to eq Date.today.end_of_month
    end
  end
end
