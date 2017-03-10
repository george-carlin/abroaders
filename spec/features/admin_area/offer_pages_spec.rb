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

    describe "new page" do
      let(:bank) { create(:bank) }
      before do
        @product = create(
          :card_product,
          name:    "Sapphire Preferred",
          network: :visa,
          annual_fee_cents: 150_000,
          bp: :business,
          bank: bank,
        )

        visit new_admin_card_product_offer_path(@product)
      end

      let(:submit) { click_button t("admin.offers.submit") }

      it { is_expected.to have_title full_title("New Offer") }

      it "displays information about the product" do
        expect(page).to have_content bank.name
        expect(page).to have_content "Sapphire Preferred"
        expect(page).to have_content "Visa"
        expect(page).to have_content "$1,500"
        expect(page).to have_content "business"
      end

      it "has fields for an offer" do
        expect(page).to have_field :offer_condition
        expect(page).to have_field :offer_points_awarded
        expect(page).to have_field :offer_spend
        expect(page).to have_field :offer_cost
        expect(page).to have_field :offer_days
        expect(page).to have_field :offer_partner
        expect(page).to have_field :offer_link
        expect(page).to have_field :offer_notes
      end

      let(:new_offer) { Offer.last }

      describe "the 'condition' dropdown" do
        it "has 'on minimum spend' selected by default" do
          selected_opt = find("#offer_condition option[selected]")
          expect(selected_opt.value).to eq "on_minimum_spend"
        end
      end

      describe "selecting 'on approval' condition'", :js do
        before { select approval, from: :offer_condition }
        it "hides the irrelevant inputs" do
          expect(page).to have_no_field :offer_spend
          expect(page).to have_no_field :offer_days
        end

        describe "and selecting 'minimum spend' again" do
          before { select minimum_spend, from: :offer_condition }
          it "shows the inputs again" do
            expect(page).to have_field :offer_spend
            expect(page).to have_field :offer_days
          end
        end

        describe "and submitting the form with valid info" do
          before do
            fill_in :offer_points_awarded, with: 40_000
            fill_in :offer_link, with: "http://something.com"
          end

          it "creates an offer" do
            expect { submit }.to change { Offer.count }.by 1
            expect(new_offer.condition).to eq "on_approval"
            expect(new_offer.product).to eq @product
            expect(new_offer.points_awarded).to eq 40_000
            expect(new_offer.link).to eq "http://something.com"
          end

          it "doesn't save any values for the irrelevant columns" do
            submit
            expect(new_offer.spend).to be_nil
            expect(new_offer.days).to be_nil
          end
        end

        describe "and submitting the form with invalid info" do
          before { submit }
          it "shows the form again with the correct fields hidden/shown" do
            expect(page).to have_field :offer_condition
            expect(page).to have_field :offer_points_awarded
            expect(page).to have_no_field :offer_spend
            expect(page).to have_field :offer_cost
            expect(page).to have_no_field :offer_days
            expect(page).to have_field :offer_link
            expect(page).to have_field :offer_notes
          end
        end
      end

      describe "selecting 'on first purchase' condition'", :js do
        before { select first_purchase, from: :offer_condition }
        it "hides the irrelevant inputs" do
          expect(page).to have_no_field :offer_spend
        end

        describe "and selecting 'minimum spend' again" do
          before { select minimum_spend, from: :offer_condition }
          it "shows the inputs again" do
            expect(page).to have_field :offer_spend
          end
        end

        describe "and submitting the form with valid info" do
          before do
            fill_in :offer_points_awarded, with: 40_000
            fill_in :offer_link, with: "http://something.com"
            fill_in :offer_days, with: 120
          end

          it "creates an offer" do
            expect { submit }.to change { Offer.count }.by 1
            expect(new_offer.condition).to eq "on_first_purchase"
            expect(new_offer.product).to eq @product
            expect(new_offer.days).to eq 120
            expect(new_offer.points_awarded).to eq 40_000
            expect(new_offer.link).to eq "http://something.com"
          end

          it "doesn't save any values for the irrelevant columns" do
            submit
            expect(new_offer.spend).to be_nil
          end
        end

        describe "and submitting the form with invalid info" do
          before { submit }
          it "shows the form again with the correct fields hidden/shown" do
            expect(page).to have_field :offer_condition
            expect(page).to have_field :offer_partner
            expect(page).to have_field :offer_points_awarded
            expect(page).to have_no_field :offer_spend
            expect(page).to have_field :offer_cost
            expect(page).to have_field :offer_days
            expect(page).to have_field :offer_link
            expect(page).to have_field :offer_notes
          end
        end
      end

      describe "the 'partner' dropdown" do
        it "has 'None' selected by default" do
          selected_opt = find("#offer_partner")
          expect(selected_opt.value).to eq ""
        end
      end

      describe "selecting 'CardRatings.com' partner", :js do
        describe "and submitting the form with valid info" do
          before do
            select card_ratings, from: :offer_partner
            fill_in :offer_points_awarded, with: 40_000
            fill_in :offer_link, with: "http://something.com"
          end

          it "creates an offer" do
            expect { submit }.to change { ::Offer.count }.by 1
            expect(new_offer.partner).to eq "card_ratings"
          end
        end
      end

      describe "submitting the form with valid information" do
        before do
          select award_wallet, from: :offer_partner
          fill_in :offer_points_awarded, with: 40_000
          fill_in :offer_spend, with: 5000
          fill_in :offer_link, with: "http://something.com"
        end

        it "creates a new offer" do
          expect { submit }.to change { Offer.count }.by(1)
          expect(new_offer.condition).to eq "on_minimum_spend"
          expect(new_offer.partner).to eq "award_wallet"
        end

        describe "the created offer" do
          before { submit }
          it "has the correct attributes" do
            expect(new_offer.product).to eq @product
            expect(new_offer.points_awarded).to eq 40_000
            expect(new_offer.spend).to eq 5_000
            expect(new_offer.link).to eq "http://something.com"
          end
        end
      end

      describe "submitting the form with invalid information" do
        before { submit }

        it "shows the form again with an error message" do
          expect(page).to have_selector "form#new_offer"
          expect(page).to have_error_message
        end

        specify "the error message talks about the 'offer'" do # bug fix
          within ".alert.alert-danger" do
            expect(page).to have_content "offer"
          end
        end
      end

      describe "the 'Link' input" do
        let(:input) { find("#offer_link") }
        it "is a text field" do # bug fix
          expect(input[:type]).to eq "text"
        end
      end
    end # new page

    describe 'index page' do
      let!(:offer) { create(:live_offer, last_reviewed_at: Time.zone.yesterday) }

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
      let(:offer)   { create(:offer, notes: 'aisjhdoifajsdf') }
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
      let(:offer)   { create(:offer) }
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
