require "rails_helper"

describe "onboarding survey - cards" do
  subject { page }

  include_context "logged in"

  before do
    @cards = [
      @chase_b    = create(:card, :business, bank: :chase),
      @chase_p    = create(:card, :personal, bank: :chase),
      @citibank_b = create(:card, :business, bank: :citibank),
      @citibank_p = create(:card, :personal, bank: :citibank),
      @barclays_b = create(:card, :business, bank: :barclays),
      @barclays_p = create(:card, :personal, bank: :barclays)
    ]
    visit card_survey_path
  end

  HEADER_TYPE = "h3"

  def bank_div_selector(bank)
    "##{bank}_cards"
  end

  def bank_bp_div_selector(bank, bp)
    "##{bank}_#{bp}_cards"
  end

  def card_checkbox(card)
    :"card_account_card_ids_#{card.id}"
  end


  it "lists cards grouped by bank, then B/P" do
    is_expected.to have_selector HEADER_TYPE, text: "Chase Personal Cards"
    is_expected.to have_selector bank_div_selector(:chase)
    is_expected.to have_selector bank_bp_div_selector(:chase, :personal)

    is_expected.to have_selector HEADER_TYPE, text: "Chase Business Cards"
    is_expected.to have_selector bank_div_selector(:chase)
    is_expected.to have_selector bank_bp_div_selector(:chase, :business)

    is_expected.to have_selector HEADER_TYPE, text: "Citibank Personal Cards"
    is_expected.to have_selector bank_div_selector(:citibank)
    is_expected.to have_selector bank_bp_div_selector(:citibank, :personal)

    is_expected.to have_selector HEADER_TYPE, text: "Citibank Business Cards"
    is_expected.to have_selector bank_div_selector(:citibank)
    is_expected.to have_selector bank_bp_div_selector(:citibank, :business)

    is_expected.to have_selector HEADER_TYPE, text: "Barclays Personal Cards"
    is_expected.to have_selector bank_div_selector(:barclays)
    is_expected.to have_selector bank_bp_div_selector(:barclays, :personal)

    is_expected.to have_selector HEADER_TYPE, text: "Barclays Business Cards"
    is_expected.to have_selector bank_div_selector(:barclays)
    is_expected.to have_selector bank_bp_div_selector(:barclays, :business)
  end

  it "has a checkbox for each card" do
    @cards.each do |card|
      is_expected.to have_field card_checkbox(card)
    end
  end


  describe "selecting some cards" do
    before do
      check card_checkbox(@chase_b)
      check card_checkbox(@citibank_b)
      check card_checkbox(@citibank_p)
    end

    describe "and clicking 'submit'" do
      let(:submit) { click_button "Save" }

      it "creates the 'existing cards' for the user" do
        expect { submit }.to change{user.card_accounts.unknown.count}.by(3)
        accounts = user.card_accounts
        expect(accounts.map(&:card)).to match_array [
          @chase_b, @citibank_p, @citibank_b
        ]
      end
    end
  end

end
