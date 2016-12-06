require 'rails_helper'

RSpec.describe Product::Cell::Admin::OffersTable, type: :view do
  let(:person)  { create(:person) }
  let(:product) { create(:product) }
  let!(:offers) { create_list(:offer, 2, product: product) }
  let!(:dead_offer) { create(:offer, :dead, product: product) }

  let(:rendered) do
    described_class.(product, person: person, context: CELL_CONTEXT).show
  end

  example "lists the product's live offers" do
    offers.each do |offer|
      expect(rendered).to have_selector offer_selector(offer)
      within offer_selector(offer) do
        expect(rendered).to have_button 'Recommend'
        expect(rendered).to have_link 'Link', href: offer.link, target: '_blank'
      end
    end

    expect(rendered).not_to have_selector offer_selector(dead_offer)
  end

  def offer_selector(offer)
    '#' << dom_id(offer, :admin_recommend)
  end
end
