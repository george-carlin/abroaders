require 'rails_helper'

RSpec.describe CardProduct do
  example '.recommendable' do
    # product with no offers:
    create(:product)

    product_with_no_live_offers = create(:product)
    kill_offer(create_offer(product: product_with_no_live_offers))

    product_with_live_offers = create(:product)
    create_offer(product: product_with_live_offers)
    create_offer(product: product_with_live_offers)

    expect(described_class.recommendable).to eq [product_with_live_offers]
  end
end
