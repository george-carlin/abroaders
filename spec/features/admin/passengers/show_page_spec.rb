require "rails_helper"

describe "admin section" do
  describe "show user page" do
    subject { page }

    include_context "logged in as admin"

    let(:phone_number) { "(555) 000-1234" }

    before do
      @currencies = create_list(:currency, 4)
      @cards = [
        @chase_business = create(
          :card, :business, bank: :chase, currency: @currencies[0]
        ),
        @chase_personal = create(
          :card, :personal, bank: :chase, currency: @currencies[1]
        ),
        @usb_business   = create(
          :card, :business, bank: :us_bank, currency: @currencies[2]
        ),
        @usb_personal   = create(
          :card, :personal, bank: :us_bank, currency: @currencies[3]
        )
      ]

      # create(:card_offer, card: @chase_business)
      # create(:card_offer, card: @chase_business)
      # create(:card_offer, card: @chase_personal)
      # create(:card_offer, card: @usb_business)

      @passenger = create(
        :passenger,
        first_name:   "Fred",
        middle_names: "R. J.",
        last_name:    "Smith",
        phone_number: phone_number,
        citizenship: :us_permanent_resident
      )
      @account   = @passenger.account
      @account.update_attributes!(time_zone: "Eastern Time (US & Canada)")
      extra_setup
      visit admin_passenger_path(@passenger)
    end

    let(:extra_setup) { nil }

    shared_examples "does not have recommend or assign links" do
      it "does not have links to recommend or assign a card" do
        is_expected.to have_no_link "Recommend",
              href: new_admin_passenger_card_recommendation_path(@passenger)
        is_expected.to have_no_link "Assign",
              href: new_admin_passenger_card_path(@passenger)
      end
    end

    it "says whether this is the main or companion passenger"

    it "has the passenger's name as the page header" do
      is_expected.to have_selector "h1", text: "Fred R. J. Smith"
    end

    it "displays the passenger's info" do
      is_expected.to have_info "email", @passenger.email
      is_expected.to have_info "phone-number", phone_number
      is_expected.to have_info "citizenship", "U.S. Permanent Resident"
    end

    context "when the passenger" do
      context "has not yet added their spending info" do
        it "says so" do
          is_expected.to have_content t("admin.passengers.show.no_spending")
          is_expected.to have_no_content \
                                  t("admin.passengers.show.not_onboarded")
        end

        include_examples "does not have recommend or assign links"
      end

      context "has added their spending info" do
        let(:extra_setup) do
          @passenger.create_spending_info!(
            credit_score: 678,
            personal_spending: 2500,
            has_business: :with_ein,
            business_spending: 1500
          )
          if onboarded
            @account.update_attributes!(onboarding_stage: :onboarded)
          end
        end
        let(:onboarded) { false }

        it "displays the spending info" do
          is_expected.to have_info "credit-score", 678
          is_expected.to have_info "personal-spending", "$2500"
          is_expected.to have_info "business-spending", "$1500"
        end

        context "but the account is still not fully onboarded" do
          it "says so" do
            is_expected.to have_no_content \
                                        t("admin.passengers.show.no_spending")
            is_expected.to have_content t("admin.passengers.show.not_onboarded")
          end

          include_examples "does not have recommend or assign links"
        end

        context "and the account is fully onboarded" do
          let(:onboarded) { true }
          it "has links to recommend or assign a card" do
            is_expected.to have_link "Recommend",
                href: new_admin_passenger_card_recommendation_path(@passenger)
            is_expected.to have_link "Assign",
                href: new_admin_passenger_card_path(@passenger)
          end
        end
      end
    end

    def card_account_selector(account)
      "#card_account_#{account.id}"
    end

    def card_radio_btn(card)
      "input#card_account_card_id_#{card.id}"
    end

    def have_info(attr, value)
      have_selector ".passenger-#{attr}", text: value
    end

  end
end
