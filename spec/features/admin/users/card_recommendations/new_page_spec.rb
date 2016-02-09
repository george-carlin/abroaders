require "rails_helper"
# Requiring this file uncovers a bug: the page wasn't working if
# ::CardAccountsController got loaded before Admin::CardAccountsController
require Rails.root.join "app", "controllers", "card_accounts_controller"

describe "admin section" do
  include_context "logged in as admin"
  subject { page }

  describe "user recommend card page" do
    subject { page }

    let(:phone_number) { "(555) 000-1234" }

    before do
      @cards = [
        @chase_business = create(
          :card, :business, bank: :chase, currency_id: "alaska"
        ),
        @chase_personal = create(
          :card, :personal, bank: :chase, currency_id: "american",
        ),
        @usb_business   = create(
          :card, :business, bank: :us_bank, currency_id: "amex",
        ),
        @usb_personal   = create(
          :card, :personal, bank: :us_bank, currency_id: "ba",
        )
      ]

      @offers = [
        create(:card_offer, card: @chase_business),
        create(:card_offer, card: @chase_business),
        create(:card_offer, card: @chase_personal),
        create(:card_offer, card: @usb_business),
        create(:card_offer, card: @usb_personal)
      ]

      @user = create(:user)
      if completed_survey
        @user.create_info!(
          first_name:   "Fred",
          middle_names: "R. J.",
          last_name:    "Smith",
          phone_number: phone_number,
          citizenship: :us_permanent_resident,
          credit_score: 678,
          personal_spending: 2500,
          has_business: :with_ein,
          business_spending: 1500,
          time_zone: "Eastern Time (US & Canada)"
        )
      end
      visit new_admin_user_card_recommendation_path(@user)
    end

    let(:completed_survey) { true }

    it "shows the date on which the user signed up" do
      is_expected.to have_content @user.created_at.strftime("%D")
    end

    context "when the user" do
      context "has not completed the onboarding survey" do
        let(:completed_survey) { false }

        it "redirects back to the user info page" do
          raise unless @user.info.nil? # Sanity check
          expect(current_path).to eq admin_user_path(@user)
          expect(page).to have_content \
                      t("admin.users.card_recommendations.no_survey")
        end
      end

      context "has no existing card accounts/recommendations" do
        it { is_expected.to have_content t("admin.users.card_accounts.none") }
      end
    end

    it "displays the user's info from the onboarding survey" do
      def have_user_info(attr, value)
        have_selector ".user-info-attr.user-#{attr}", text: value
      end

      is_expected.to have_user_info "email", @user.email
      is_expected.to have_user_info "phone-number", phone_number
      is_expected.to have_user_info "citizenship", "U.S. Permanent Resident"
      is_expected.to have_user_info "credit-score", 678
      is_expected.to have_user_info "personal-spending", "$2500"
      is_expected.to have_user_info "business-spending", "$1500"
    end

    it "has a form to recommend a new card" do
      is_expected.to have_selector ".admin-card-recommendation-table"
    end

    describe "the card recommendation form" do
      it "has an option to recommend each card offer" do
        within ".admin-card-recommendation-table" do
          @offers.each do |offer|
            is_expected.to have_selector "##{dom_id(offer, :admin_recommend)}"
            is_expected.to have_selector "#recommend_#{dom_id(offer)}_btn"
          end
        end
      end

      describe "filters", js: true do
        def should_have_recommendable_cards(*cards)
          cards.each { |card| should have_recommendable_card(card) }
        end

        def should_not_have_recommendable_cards(*cards)
          cards.each { |card| should_not have_recommendable_card(card) }
        end

        describe "the cards" do
          specify "can be filtered by b/p" do
            uncheck :card_bp_filter_business
            should_have_recommendable_cards(@chase_personal, @usb_personal)
            should_not_have_recommendable_cards(@chase_business, @usb_business)
            uncheck :card_bp_filter_personal
            should_not_have_recommendable_cards(*@cards)
            check :card_bp_filter_business
            should_have_recommendable_cards(@chase_business, @usb_business)
            should_not_have_recommendable_cards(@chase_personal, @usb_personal)
            check :card_bp_filter_personal
            should_have_recommendable_cards(*@cards)
          end

          specify "can be filtered by bank" do
            Card.banks.keys.each do |bank|
              is_expected.to have_field :"card_bank_filter_#{bank}"
            end

            uncheck :card_bank_filter_chase
            should_have_recommendable_cards(@usb_business, @usb_personal)
            should_not_have_recommendable_cards(@chase_business, @chase_personal)
            uncheck :card_bank_filter_us_bank
            should_not_have_recommendable_cards(*@cards)
            check :card_bank_filter_chase
            should_have_recommendable_cards(@chase_business, @chase_personal)
            should_not_have_recommendable_cards(@usb_business, @usb_personal)
            check :card_bank_filter_us_bank
            should_have_recommendable_cards(*@cards)
          end

          specify "can be filtered by currency" do
            Currency.keys.each do |currency|
              is_expected.to have_field :"card_currency_filter_#{currency}"
            end

            # Alternative variables names for readability:
            alaska_card   = @chase_business
            american_card = @chase_personal
            amex_card     = @usb_business
            ba_card       = @usb_personal

            uncheck :card_currency_filter_alaska
            uncheck :card_currency_filter_american
            should_have_recommendable_cards(amex_card, ba_card)
            should_not_have_recommendable_cards(alaska_card, american_card)
            uncheck :card_currency_filter_amex
            uncheck :card_currency_filter_ba
            should_not_have_recommendable_cards(*@cards)
            check :card_currency_filter_american
            should_have_recommendable_cards(american_card)
          end
        end

        describe "the 'toggle all banks' checkbox" do
          it "toggles all banks on/off" do
            uncheck :card_bank_filter_all
            should_not_have_recommendable_cards(*@cards)
            Card.banks.keys.each do |bank|
              expect(find("#card_bank_filter_#{bank}")).not_to be_checked
            end
            check :card_bank_filter_all
            should_have_recommendable_cards(*@cards)
            Card.banks.keys.each do |bank|
              expect(find("#card_bank_filter_#{bank}")).to be_checked
            end
          end

          it "is checked/unchecked automatically as I click other CBs" do
            uncheck :card_bank_filter_chase
            expect(find("#card_bank_filter_all")).not_to be_checked
            check :card_bank_filter_chase
            expect(find("#card_bank_filter_all")).to be_checked
          end
        end
      end # filters

      describe "clicking 'recommend' next to a card offer", js: true do
        let(:offer) { @offers[3] }
        before { find("#recommend_#{dom_id(offer)}_btn").click }
        let(:offer_tr) { "##{dom_id(offer, :admin_recommend)}" }

        it "shows confirm/cancel buttons" do
          within offer_tr do
            is_expected.not_to have_button "Recommend"
            is_expected.to have_button "Cancel"
            is_expected.to have_button "Confirm"
          end
        end

        describe "clicking 'Confirm'" do
          let(:confirm) do
            within offer_tr do
              click_button "Confirm"
            end
          end

          it "recommends that card to the user" do
            expect{confirm}.to change{CardAccount.recommended.count}.by(1)
          end

          describe "the new recommendation" do
            before { confirm }

            let(:rec) { CardAccount.recommended.last }

            it "has the correct offer, card, and user" do
              expect(rec.card).to eq offer.card
              expect(rec.offer).to eq offer
              expect(rec.user).to eq @user
            end

            it "has 'recommended at' set to the current time" do
              expect(rec.recommended_at).to be_within(5.seconds).of Time.now
            end
          end
        end # clicking 'Confirm'

        describe "clicking 'Cancel'" do
          let(:cancel) do
            within offer_tr do
              click_button "Cancel"
            end
          end

          it "doesn't recommend the card to the user" do
            expect{cancel}.not_to change{CardAccount.count}
          end

          it "shows the 'recommend' button again" do
            cancel
            within offer_tr do
              is_expected.to have_button "Recommend"
              is_expected.not_to have_button "Confirm"
              is_expected.not_to have_button "Cancel"
            end
          end
        end
      end
    end

    def have_recommendable_card(card)
      have_selector recommendable_card_selector(card)
    end

    def recommendable_card_selector(card)
      "##{dom_id(card, :admin_recommend)}"
    end

  end
end
