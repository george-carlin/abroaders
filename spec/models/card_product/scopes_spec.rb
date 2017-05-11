require 'rails_helper'

RSpec.describe CardProduct do
  describe "scopes" do
    example '.recommendable' do
      # card product with no offers:
      create(:card_product)

      product_with_no_live_offers = create(:card_product)
      kill_offer(create_offer(card_product: product_with_no_live_offers))

      product_with_live_offers = create(:card_product)
      create_offer(card_product: product_with_live_offers)
      create_offer(card_product: product_with_live_offers)

      expect(described_class.recommendable).to eq [product_with_live_offers]
    end

    example '.survey' do
      shown = create(:card_product, shown_on_survey: true)
      _hidden = create(:card_product, shown_on_survey: false)

      expect(described_class.survey).to match_array([shown])
    end

    example '.business & .personal' do
      b = create(:card_product, personal: false)
      p = create(:card_product, personal: true)

      expect(described_class.business).to match_array([b])
      expect(described_class.personal).to match_array([p])
    end
  end
end
