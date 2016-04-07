require "rails_helper"

describe "admin section" do
  include_context "logged in as admin"

  describe "card offers pages" do
    describe "new page" do
      before do
        @cards = create_list(:card, 2)
        visit new_admin_card_offer_path
      end

      describe "submitting the form with valid information" do
        before do
          select @cards[1].name, from: :card_offer_card_id
          fill_in :card_offer_points_awarded, with: 40_000
          fill_in :card_offer_spend, with: 5000
          fill_in :card_offer_link, with: "http://something.com"
        end

        let(:submit) { click_button t("admin.card_offers.submit") }

        it "creates a new card offer" do
          expect{submit}.to change{CardOffer.count}.by(1)
        end
      end

    end
  end
end
