require "rails_helper"

describe "admin section" do
  describe "show user page" do
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

  end
end
