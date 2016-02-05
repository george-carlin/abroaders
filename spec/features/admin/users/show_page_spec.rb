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

      create(:card_offer, card: @chase_business)
      create(:card_offer, card: @chase_business)
      create(:card_offer, card: @chase_personal)
      create(:card_offer, card: @usb_business)

      @user = create(:user)
      extra_setup
      visit admin_user_path(@user)
    end

    let(:extra_setup) { nil }


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

    def have_user_info(attr, value)
      have_selector ".user-info-attr.user-#{attr}", text: value
    end

  end
end
