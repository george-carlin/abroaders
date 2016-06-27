require "rails_helper"

describe "admin section" do
  describe "show user page" do
    subject { page }

    include_context "logged in as admin"

    before(:all) do
      @currencies = create_list(:currency, 4)
      @chase   = Bank.find_by(name: "Chase")
      @us_bank = Bank.find_by(name: "US Bank")

      def create_card(bp, bank, currency)
        create(:card, bp, bank_id: bank.id, currency: currency)
      end

      @cards = [
        @chase_business = create_card(:business, @chase,   @currencies[0]),
        @chase_personal = create_card(:personal, @chase,   @currencies[1]),
        @usb_business   = create_card(:business, @us_bank, @currencies[2]),
        @usb_personal   = create_card(:personal, @us_bank, @currencies[3]),
      ]
    end

    let(:chase)   { @chase }
    let(:us_bank) { @us_bank }

    before do
      @person = create(:person, first_name: "Fred")
      @person.eligible_to_apply!
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

    context "when the person hasn't added their spending info" do
      it "says so" do
        is_expected.to have_content "User has not added their spending info"
      end
    end

    context "when the person has added their spending info" do
      let(:extra_setup) { @info = create(:spending_info, person: @person) }
      it "displays the spending info" do
        is_expected.to have_selector "##{dom_id(@info)}"
      end
    end

    example "person has not given their eligibility"
    example "person is ineligible"

    context "person is eligible" do
      example "and has not provided readiness"
      example "and is not ready (no reason given)"
      example "and is not ready (reason given)"
      example "and is ready"
    end

  end
end
