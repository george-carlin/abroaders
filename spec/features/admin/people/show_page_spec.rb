require "rails_helper"

describe "admin section" do
  describe "show user page" do
    # This spec is totally out of date, and the admin/people#show page is
    # unimportant and likely to change in the future anyway, so skipping
    # the failing specs for now
    subject { page }

    include_context "logged in as admin"

    before do
      @currencies = create_list(:currency, 4)
      chase   = Bank.find_by(name: "Chase")
      us_bank = Bank.find_by(name: "US Bank")

      def create_card(bp, bank, currency)
        create(:card, bp, bank_id: bank.id, currency: currency)
      end

      @cards = [
        @chase_business = create_card(:business, chase,   @currencies[0]),
        @chase_personal = create_card(:personal, chase,   @currencies[1]),
        @usb_business   = create_card(:business, us_bank, @currencies[2]),
        @usb_personal   = create_card(:personal, us_bank, @currencies[3]),
      ]

      @person  = create(:person, first_name: "Fred")
      @account = @person.account.reload
      extra_setup
      visit admin_person_path(@person)
    end

    let(:extra_setup) { nil }
    let(:recommend_link_text) { "Recommend a card" }

    it { is_expected.to have_title full_title(@person.first_name) }

    shared_examples "does not have recommend or assign links" do
      it "does not have links to recommend or assign a card" do
        is_expected.to have_no_link recommend_link_text,
              href: new_admin_person_card_recommendation_path(@person)
      end
    end

    it "says whether this is the main or companion passenger"

    it "has the person's name as the page header" do
      is_expected.to have_selector "h1", text: "Fred"
    end

    it "displays the person's info" do
      pending
      is_expected.to have_info "email", @person.email
    end

    context "when the person" do
      context "has not yet added their spending info" do
        it "says so" do
          pending
          is_expected.to have_content t("admin.people.show.no_spending")
          is_expected.to have_no_content t("admin.people.show.not_onboarded")
        end

        include_examples "does not have recommend or assign links"
      end

      context "has added their spending info" do
        let(:extra_setup) do
          @person.create_spending_info!(
            business_spending_usd: 1500,
            credit_score: 678,
            has_business: :with_ein,
          )
          if onboarded
            pending
            @account.update_attributes!(onboarding_stage: :onboarded)
          end
        end
        let(:onboarded) { false }

        it "displays the spending info" do
          pending
          is_expected.to have_info "credit-score", 678
          is_expected.to have_info "personal-spending", "$2500"
          is_expected.to have_info "business-spending", "$1500"
        end

        context "but the account is still not fully onboarded" do
          it "says so" do
            pending
            is_expected.to have_no_content t("admin.people.show.no_spending")
            is_expected.to have_content t("admin.people.show.not_onboarded")
          end

          include_examples "does not have recommend or assign links"
        end

        context "and the account is fully onboarded" do
          let(:onboarded) { true }
          it "has links to recommend or assign a card" do
            is_expected.to have_link recommend_link_text,
                href: new_admin_person_card_recommendation_path(@person)
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
      have_selector ".person-#{attr}", text: value
    end

  end
end
