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
      @currencies = create_list(:currency, 4)

      @cards = [
        @chase_b = create(:card, :business, :chase, currency: @currencies[0]),
        @chase_p = create(:card, :personal, :chase, currency: @currencies[1]),
        @usb_b = create(:card, :business, :us_bank, currency: @currencies[2]),
        @usb_p = create(:card, :personal, :us_bank, currency: @currencies[3])
      ]

      @offers = [
        create(:card_offer, card: @chase_b),
        create(:card_offer, card: @chase_b),
        create(:card_offer, card: @chase_p),
        create(:card_offer, card: @usb_b),
        create(:card_offer, card: @usb_p)
      ]

      @user = create(:user)
      if completed_survey
        @user.create_survey!(
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
      extra_setup
      visit new_admin_user_card_recommendation_path(@user)
    end

    let(:completed_survey) { true }
    let(:extra_setup) { nil }

    it "shows the date on which the user signed up" do
      is_expected.to have_content @user.created_at.strftime("%D")
    end

    context "when the user" do
      context "has not completed the onboarding survey" do
        let(:completed_survey) { false }

        it "redirects back to the user survey page" do
          raise unless @user.survey.nil? # Sanity check
          expect(current_path).to eq admin_user_path(@user)
          expect(page).to have_content \
                      t("admin.users.card_recommendations.no_survey")
        end
      end

      context "has no existing card accounts/recommendations" do
        it { is_expected.to have_content t("admin.users.card_accounts.none") }
      end

      context "has no travel plans" do
        it { is_expected.to have_content "User has no upcoming travel plans" }
      end

      context "has added travel plans" do
        let(:extra_setup) do
          @eu  = create(:region,  name: "Europe")
          @uk  = create(:country, name: "UK",       parent: @eu)
          @lhr = create(:airport, name: "Heathrow", parent: @uk)

          @as  = create(:region,  name: "Asia")
          @vn  = create(:country, name: "Vietnam", parent: @as)
          @sgn = create(:airport, name: "HCMC",    parent: @vn)

          @na  = create(:region,  name: "North America")
          @us  = create(:country, name: "United States", parent: @na)
          @jfk = create(:airport, name: "JFK",           parent: @us)

          @tp_0 = create(
            :travel_plan, :single, user: @user,
            flights: [Flight.new(from: @jfk, to: @lhr)]
          )
          @tp_1 = create(
            :travel_plan, :return, user: @user,
            flights: [Flight.new(from: @na, to: @as)]
          )
          @tp_2 = create(
            :travel_plan, :multi, user: @user,
            flights: [
              Flight.new(from: @jfk, to: @eu, position: 0),
              Flight.new(from: @eu,  to: @vn, position: 1),
              Flight.new(from: @sgn, to: @jfk, position: 2)
            ]
          )
        end

        it "displays information about them" do
          is_expected.not_to have_content "User has no upcoming travel plans"

          # When the destination is a region, just display the region name.
          # When the destination is anything other than a region, display the
          # destination name, and the region name, skipping any intermediary
          # steps. E.g. if the destination is Heathrow, display "Heathrow
          # (Europe)", and don't bother displaying the intermediary
          # destinations like London, England, UK, etc.

          within ".user_travel_plans" do
            is_expected.to have_selector "##{dom_id(@tp_0)}"
            within "##{dom_id(@tp_0)}" do
              is_expected.to have_content "Single"
              is_expected.to have_selector "##{dom_id(@tp_0.flights[0])}"
              within "##{dom_id(@tp_0.flights[0])}" do
                is_expected.to have_content "JFK (North America)"
                is_expected.to have_content "Heathrow (Europe)"
              end
            end

            is_expected.to have_selector "##{dom_id(@tp_1)}"
            within "##{dom_id(@tp_1)}" do
              is_expected.to have_content "Return"
              is_expected.to have_selector "##{dom_id(@tp_1.flights[0])}"
              within "##{dom_id(@tp_1.flights[0])}" do
                is_expected.to have_content "North America"
                is_expected.to have_content "Asia"
              end
            end

            is_expected.to have_selector "##{dom_id(@tp_2)}"
            within "##{dom_id(@tp_2)}" do
              is_expected.to have_content "Multi"
              is_expected.to have_selector "##{dom_id(@tp_2.flights[0])}"
              is_expected.to have_selector "##{dom_id(@tp_2.flights[1])}"
              is_expected.to have_selector "##{dom_id(@tp_2.flights[2])}"

              within "##{dom_id(@tp_2.flights[0])}" do
                is_expected.to have_content "JFK (North America)"
                is_expected.to have_content "Europe"
              end
              within "##{dom_id(@tp_2.flights[1])}" do
                is_expected.to have_content "Europe"
                is_expected.to have_content "Vietnam (Asia)"
              end
              within "##{dom_id(@tp_2.flights[2])}" do
                is_expected.to have_content "HCMC (Asia)"
                is_expected.to have_content "JFK (North America)"
              end
            end
          end
        end
      end

      context "has no existing points balances" do
        it do
          is_expected.to have_content \
            t("admin.users.card_recommendations.no_balances")
        end
      end

      context "has existing points balances" do
        let(:extra_setup) do
          Balance.create!(user: @user, currency: @currencies[0], value:  5000)
          Balance.create!(user: @user, currency: @currencies[2], value: 10000)
        end

        it "lists their balances" do
          is_expected.to have_selector "##{dom_id(@currencies[0])} .balance",
                                        text: "5,000"
          is_expected.to have_selector "##{dom_id(@currencies[2])} .balance",
                                        text: "10,000"

          is_expected.not_to have_selector "##{dom_id(@currencies[1])}_balance"
          is_expected.not_to have_selector "##{dom_id(@currencies[3])}_balance"
        end
      end
    end

    it "displays the user's info from the onboarding survey" do
      def have_survey_info(attr, value)
        have_selector ".user-survey-attr.user-#{attr}", text: value
      end

      is_expected.to have_survey_info "email", @user.email
      is_expected.to have_survey_info "phone-number", phone_number
      is_expected.to have_survey_info "citizenship", "U.S. Permanent Resident"
      is_expected.to have_survey_info "credit-score", 678
      is_expected.to have_survey_info "personal-spending", "$2500"
      is_expected.to have_survey_info "business-spending", "$1500"
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

      describe "filters", :js do
        def should_have_recommendable_cards(*cards)
          cards.each { |card| should have_recommendable_card(card) }
        end

        def should_not_have_recommendable_cards(*cards)
          cards.each { |card| should_not have_recommendable_card(card) }
        end

        describe "the cards" do
          specify "can be filtered by b/p" do
            uncheck :card_bp_filter_business
            should_have_recommendable_cards(@chase_p, @usb_p)
            should_not_have_recommendable_cards(@chase_b, @usb_b)
            uncheck :card_bp_filter_personal
            should_not_have_recommendable_cards(*@cards)
            check :card_bp_filter_business
            should_have_recommendable_cards(@chase_b, @usb_b)
            should_not_have_recommendable_cards(@chase_p, @usb_p)
            check :card_bp_filter_personal
            should_have_recommendable_cards(*@cards)
          end

          specify "can be filtered by bank" do
            Card.banks.keys.each do |bank|
              is_expected.to have_field :"card_bank_filter_#{bank}"
            end

            uncheck :card_bank_filter_chase
            should_have_recommendable_cards(@usb_b, @usb_p)
            should_not_have_recommendable_cards(@chase_b, @chase_p)
            uncheck :card_bank_filter_us_bank
            should_not_have_recommendable_cards(*@cards)
            check :card_bank_filter_chase
            should_have_recommendable_cards(@chase_b, @chase_p)
            should_not_have_recommendable_cards(@usb_b, @usb_p)
            check :card_bank_filter_us_bank
            should_have_recommendable_cards(*@cards)
          end

          specify "can be filtered by currency" do
            Currency.pluck(:id).each do |currency_id|
              is_expected.to have_field :"card_currency_filter_#{currency_id}"
            end

            uncheck "card_currency_filter_#{@chase_b.id}"
            uncheck "card_currency_filter_#{@chase_p.id}"
            should_have_recommendable_cards(@usb_p, @usb_p)
            should_not_have_recommendable_cards(@chase_b, @chase_p)
            uncheck "card_currency_filter_#{@usb_b.id}"
            uncheck "card_currency_filter_#{@usb_p.id}"
            should_not_have_recommendable_cards(*@cards)
            check "card_currency_filter_#{@chase_p.id}"
            should_have_recommendable_cards(@chase_p)
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

      describe "clicking 'recommend' next to a card offer", :js do
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
