require "rails_helper"

describe "admin section" do
  include_context "logged in as admin"
  subject { page }

  describe "card offers pages" do
    describe "new page" do
      before do
        @cards = [
          create(
            :card,
            name:    "Sapphire Preferred",
            network: :visa,
            annual_fee_cents: 1500,
            bp:   :business,
            bank: Bank.find_by(name: "Chase")
          ),
          create(
            :card,
            name:    "Premier",
            network: :mastercard,
            annual_fee_cents: 500,
            bp:   :personal,
            bank: Bank.find_by(name: "Citibank")
          ),
        ]

        visit new_admin_card_offer_path
      end

      let(:submit) { click_button t("admin.card_offers.submit") }

      it { is_expected.to have_title full_title("New Card Offer") }

      describe "submitting the form with valid information" do
        before do
          select @cards[1].name, from: :card_offer_card_id
          fill_in :card_offer_points_awarded, with: 40_000
          fill_in :card_offer_spend, with: 5000
          fill_in :card_offer_link, with: "http://something.com"
        end

        it "creates a new card offer" do
          expect{submit}.to change{CardOffer.count}.by(1)
        end
      end

      describe "submitting the form with invalid information" do
        before { submit }

        it "shows the form again with an error message" do
          expect(page).to have_selector "form#new_card_offer"
          expect(page).to have_error_message
        end

        specify "the error message talks about the 'card offer'" do # bug fix
          within ".alert.alert-danger" do
            expect(page).to have_content "card offer"
          end
        end
      end

      describe "the 'Link' input" do
        let(:input) { find("#card_offer_link") }
        it "is a text field" do # bug fix
          expect(input[:type]).to eq "text"
        end
      end

      describe "the 'card' dropdown" do
        it "gives a full description of each card" do
          expect(all("#card_offer_card_id > option").map(&:text)).to \
            match_array([
              "Chase Sapphire Preferred business Visa",
              "Citibank Premier personal MasterCard",
            ])
        end
      end
    end
  end
end
