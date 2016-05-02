require "rails_helper"

describe "admin section" do
  include_context "logged in as admin"
  subject { page }

  describe "offers pages" do
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

        visit new_admin_offer_path
      end

      let(:submit) { click_button t("admin.offers.submit") }

      it { is_expected.to have_title full_title("New Offer") }

      it "has fields for an offer" do
        is_expected.to have_field :offer_card_id
        is_expected.to have_field :offer_condition
        is_expected.to have_field :offer_points_awarded
        is_expected.to have_field :offer_spend
        is_expected.to have_field :offer_cost
        is_expected.to have_field :offer_days
        is_expected.to have_field :offer_link
        is_expected.to have_field :offer_notes
      end

      let(:approval)       { t("activerecord.attributes.offer.conditions.on_approval") }
      let(:first_purchase) { t("activerecord.attributes.offer.conditions.on_first_purchase") }
      let(:minimum_spend)  { t("activerecord.attributes.offer.conditions.on_minimum_spend") }

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
          is_expected.not_to have_field :offer_spend
          is_expected.not_to have_field :offer_days
        end

        describe "and selecting 'minimum spend' again" do
          before { select minimum_spend, from: :offer_condition }
          it "shows the inputs again" do
            is_expected.to have_field :offer_spend
            is_expected.to have_field :offer_days
          end
        end

        describe "and submitting the form with valid info" do
          before do
            select @cards[1].name, from: :offer_card_id
            fill_in :offer_points_awarded, with: 40_000
            fill_in :offer_link, with: "http://something.com"
          end

          it "creates an offer" do
            expect{submit}.to change{Offer.count}.by 1
            expect(new_offer.condition).to eq "on_approval"
            expect(new_offer.card).to eq @cards[1]
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
            is_expected.to have_field :offer_card_id
            is_expected.to have_field :offer_condition
            is_expected.to have_field :offer_points_awarded
            is_expected.not_to have_field :offer_spend
            is_expected.to have_field :offer_cost
            is_expected.not_to have_field :offer_days
            is_expected.to have_field :offer_link
            is_expected.to have_field :offer_notes
          end
        end
      end

      describe "selecting 'on first purchase' condition'", :js do
        before { select first_purchase, from: :offer_condition }
        it "hides the irrelevant inputs" do
          is_expected.not_to have_field :offer_spend
        end

        describe "and selecting 'minimum spend' again" do
          before { select minimum_spend, from: :offer_condition }
          it "shows the inputs again" do
            is_expected.to have_field :offer_spend
          end
        end

        describe "and submitting the form with valid info" do
          before do
            select @cards[1].name, from: :offer_card_id
            fill_in :offer_points_awarded, with: 40_000
            fill_in :offer_link, with: "http://something.com"
            fill_in :offer_days, with: 120
          end

          it "creates an offer" do
            expect{submit}.to change{Offer.count}.by 1
            expect(new_offer.condition).to eq "on_first_purchase"
            expect(new_offer.card).to eq @cards[1]
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
            is_expected.to have_field :offer_card_id
            is_expected.to have_field :offer_condition
            is_expected.to have_field :offer_points_awarded
            is_expected.not_to have_field :offer_spend
            is_expected.to have_field :offer_cost
            is_expected.to have_field :offer_days
            is_expected.to have_field :offer_link
            is_expected.to have_field :offer_notes
          end
        end
      end

      describe "submitting the form with valid information" do
        before do
          select @cards[1].name, from: :offer_card_id
          fill_in :offer_points_awarded, with: 40_000
          fill_in :offer_spend, with: 5000
          fill_in :offer_link, with: "http://something.com"
        end

        it "creates a new offer" do
          expect{submit}.to change{Offer.count}.by(1)
          expect(new_offer.condition).to eq "on_minimum_spend"
        end

        context "and marking the card as not live" do
          before { uncheck :offer_live }
          it "saves the card as live" do
            submit
            expect(new_offer).not_to be_live
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

      describe "the 'card' dropdown" do
        it "gives a full description of each card" do
          expect(all("#offer_card_id > option").map(&:text)).to \
            match_array([
              "Chase Sapphire Preferred business Visa",
              "Citibank Premier personal MasterCard",
            ])
        end
      end
    end
  end
end
