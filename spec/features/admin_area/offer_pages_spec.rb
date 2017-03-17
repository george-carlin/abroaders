require 'rails_helper'

module AdminArea
  RSpec.describe 'offers pages' do
    include_context 'logged in as admin'
    subject { page }

    let(:approval)       { t("activerecord.attributes.offer.conditions.on_approval") }
    let(:first_purchase) { t("activerecord.attributes.offer.conditions.on_first_purchase") }
    let(:minimum_spend)  { t("activerecord.attributes.offer.conditions.on_minimum_spend") }

    let(:card_ratings) { "CardRatings.com" }
    let(:credit_cards) { "CreditCards.com" }
    let(:award_wallet) { "AwardWallet" }
    let(:card_benefit) { "CardBenefit" }

    describe 'index page' do
      let!(:offer) { create_offer(:verified) }

      example 'for all offers' do
        visit admin_offers_path
        expect(page).to have_content offer.product.name
        expect(find("tr#offer_#{offer.id}").text).to include(offer.last_reviewed_at.strftime('%m/%d/%Y'))
        expect(find("tr#offer_#{offer.id}").text).to include('CB')
      end

      example 'for offers for a specific card product' do
        visit admin_card_product_offers_path(offer.product)
        expect(page).to have_content offer.product.name
        expect(find("tr#offer_#{offer.id}").text).to include(offer.last_reviewed_at.strftime('%m/%d/%Y'))
        expect(find("tr#offer_#{offer.id}").text).to include('CB')
      end
    end # offers page

    describe "show page" do
      let(:offer)   { create_offer(notes: 'aisjhdoifajsdf') }
      let(:product) { offer.product }
      before { visit route }

      let(:route) { admin_card_product_offer_path(product, offer) }

      describe "when accessing the shallow path" do
        let(:route) { admin_offer_path(offer) }
        it "redirects to the nested path" do
          expect(current_path).to eq admin_card_product_offer_path(product, offer)
        end
      end

      it "displays information about the offer and product" do
        expect(page).to have_content product.name
        expect(page).to have_content card_benefit
        expect(page).to have_content offer.notes
      end
    end # show page

    describe "edit page" do
      let(:offer)   { create_offer }
      let(:product) { offer.product }
      before { visit route }

      let(:route) { edit_admin_card_product_offer_path(product, offer) }

      describe "when accessing the shallow path" do
        let(:route) { edit_admin_offer_path(offer) }
        it "redirects to the nested path" do
          expect(current_path).to eq edit_admin_card_product_offer_path(product, offer)
        end
      end

      it "displays information about the product" do
        expect(page).to have_content product.name
      end

      it "display information about the offer" do
        condition = find("#offer_condition option[selected]")
        expect(condition.value).to eq offer.condition

        partner = find("#offer_partner option[selected]")
        expect(partner.value).to eq offer.partner

        points_awarded = find("#offer_points_awarded")
        expect(points_awarded.value.to_i).to eq offer.points_awarded

        offer_spend = find("#offer_spend")
        expect(offer_spend.value.to_i).to eq offer.spend

        offer_cost = find("#offer_cost")
        expect(offer_cost.value.to_i).to eq offer.cost

        offer_days = find("#offer_days")
        expect(offer_days.value.to_i).to eq offer.days

        offer_link = find("#offer_link")
        expect(offer_link.value).to eq offer.link
      end
    end
  end
end
