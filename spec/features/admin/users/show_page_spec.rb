require "rails_helper"

describe "admin section" do
  describe "show user page" do
    subject { page }

    include_context "logged in as admin"

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

      @user = create(:user)
      extra_setup
      visit admin_user_path(@user)
    end

    let(:extra_setup) { nil }

    it "shows the date on which the user signed up" do
      is_expected.to have_content user.created_at.strftime("%D")
    end

    context "when the user" do
      context "has no existing card accounts/recommendations" do
        it "says so" do
          should have_content t("admin.users.card_accounts.none")
        end
      end

      context "has not yet completed the onboarding survey" do
        it "says so" do
          should have_content t("admin.users.show.no_survey")
        end

        it "has 'User (db ID)' as the page header" do
          is_expected.to have_selector "h1", text: "User ##{@user.id}"
        end

        it "displays the user's email address" do
          is_expected.to have_content @user.email
        end
      end

      context "has completed the onboarding survey" do
        let(:phone_number) { "(555) 000-1234" }
        let(:extra_setup) do
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

        it "has the user's name as the page header" do
          is_expected.to have_selector "h1", text: "Fred R. J. Smith"
        end

        it "displays the relevant survey information" do
          is_expected.to have_user_info "email", @user.email
          is_expected.to have_user_info "phone-number", phone_number
          is_expected.to have_user_info "citizenship", "U.S. Permanent Resident"
          is_expected.to have_user_info "credit-score", 678
          is_expected.to have_user_info "personal-spending", "$2500"
          is_expected.to have_user_info "business-spending", "$1500"
        end
      end
    end

    context "has already been recommended at least one card" do
      let(:extra_setup) do
        @recommended_card = @cards.first
        @rec = create(
          :card_recommendation, user: @user, card: @recommended_card
        )
      end

      it "lists existing card recommendations" do
        should have_selector card_account_selector(@rec)
        within card_account_selector(@rec) do
          is_expected.to have_content @rec.card_identifier
          is_expected.to have_content @rec.card_name
          is_expected.to have_content @rec.card_type.to_s.capitalize
          is_expected.to have_content @rec.card_brand.to_s.capitalize
          is_expected.to have_content @rec.card_type.to_s.capitalize
          is_expected.to have_content @rec.card_bank_name
        end
      end

      it "doesn't include those cards in the 'new recommendation' form" do
        within "form#new_card_account" do
          should_not have_selector card_radio_btn(@recommended_card)
        end
      end
    end

    it "has a form to recommend a new card" do
      within "form#new_card_account" do
        @cards.each do |card|
          should have_recommendable_card(card)
          within recommendable_card_selector(card) do
            should have_selector card_radio_btn(card)
          end
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
    end


    describe "the card account status dropdown" do
      it "is initially hidden" do
        is_expected.not_to have_field :card_account_status
      end
    end

    describe "selecting a card" do
      before do
        @card = @cards[2]
        choose :"card_account_card_id_#{@card.id}"
      end

      let(:submit) { click_button "Submit" }

      describe "and selecting 'recommend this card'" do
        before { choose :create_mode_recommendation }

        describe "and clicking 'submit'" do

          it "assigns the card to the user in the 'recommendation' stage" do
            expect{submit}.to change{CardAccount.recommended.count}.by(1)

            account = CardAccount.recommended.last
            expect(account.card).to eq @card
            expect(account.user).to eq @user
          end

          it "sets 'recommended at' to the current time" do
            submit
            account = CardAccount.recommended.last
            expect(account.recommended_at).to be_within(5.seconds).of(
              Time.now
            )
          end

          pending "notifies the user"
        end
      end

      describe "and selecting 'assign this card'", js: true do
        before { choose :create_mode_assignment }

        it "shows the card account status dropdown" do
          is_expected.to have_field :card_account_status
        end

        describe "selecting a status and submitting" do
          before { select "Denied", from: :card_account_status }

          let(:submit) { click_button "Submit" }

          it "assigns the card to the user in the 'recommendation' stage" do
            expect{submit}.to change{CardAccount.count}.by(1)

            account = CardAccount.last
            expect(account.card).to eq @card
            expect(account.user).to eq @user
            expect(account.status).to eq "denied"
          end

          it "doesn't set a 'recommended at' timestamp" do
            submit
            account = CardAccount.last
            expect(account.recommended_at).to be_nil
          end

          pending "notifies the user"
        end
      end
    end

    def card_account_selector(account)
      "#card_account_#{account.id}"
    end

    def card_radio_btn(card)
      "input#card_account_card_id_#{card.id}"
    end

    def have_recommendable_card(card)
      have_selector recommendable_card_selector(card)
    end

    def recommendable_card_selector(card)
      "##{dom_id(card, :admin_recommend)}"
    end

    def have_user_info(attr, value)
      have_selector ".user-info-attr.user-#{attr}", text: value
    end

  end
end
