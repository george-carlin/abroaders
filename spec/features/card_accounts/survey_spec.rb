require "rails_helper"

describe "as a new user" do
  subject { page }

  let!(:account) { create(:account) }
  let!(:me) { create(:person, account: account) }

  # Setup
  before do
    chase = Bank.find_by(name: "Chase")
    citi  = Bank.find_by(name: "Citibank")
    @visible_cards = [
      create(:card, :business, :visa,       bank_id: chase.id, name: "Card 0"),
      create(:card, :personal, :mastercard, bank_id: chase.id, name: "Card 1"),
      create(:card, :business, :mastercard, bank_id: citi.id,  name: "Card 2"),
      create(:card, :personal, :visa,       bank_id: citi.id,  name: "Card 3"),
    ]
    @hidden_card = create(:card, shown_on_survey: false)

    login_as account.reload
    visit survey_person_card_accounts_path(me)
  end

  let(:submit_form) { click_button "Save" }

  def card_checkbox(card)
    :"card_account_card_ids_#{card.id}"
  end

  it "lists cards grouped by bank, then B/P" do
    %w[chase citibank].each do |bank|
      %w[personal business].each do |type|
        header = "#{bank.capitalize} #{type.capitalize} Cards"
        is_expected.to have_selector "h3", text: header
        is_expected.to have_selector "##{bank.to_param}_cards"
        is_expected.to have_selector "##{bank}_#{type}_cards"
      end
    end
  end

  it "has a checkbox for each card" do
    @visible_cards.each do |card|
      is_expected.to have_field card_checkbox(card)
    end
  end

  describe "a business card's displayed name" do
    it "follows the format 'card name, BUSINESS, network, annual fee'" do
      within "##{dom_id(@visible_cards[0])}" do
        expect(page).to have_content "Card 0 business Visa"
      end
      within "##{dom_id(@visible_cards[2])}" do
        expect(page).to have_content "Card 2 business MasterCard"
      end
    end
  end

  describe "a personal card's displayed name" do
    it "follows the format 'card name, network, annual fee'" do
      within "##{dom_id(@visible_cards[1])}" do
        expect(page).to have_content "Card 1 MasterCard"
      end
      within "##{dom_id(@visible_cards[3])}" do
        expect(page).to have_content "Card 3 Visa"
      end
    end
  end

  it "doesn't show cards which the admin has opted to hide" do
    expect(page).not_to have_field card_checkbox(@hidden_card)
  end

  describe "selecting some cards" do
    let(:selected_cards) { @visible_cards.values_at(0, 2, 3) }
    before { selected_cards.each { |card| check card_checkbox(card) } }

    describe "and clicking 'Save'" do
      it "assigns the cards to the main passenger" do
        expect do
          submit_form
        end.to change{me.card_accounts.unknown.count}.by selected_cards.length
        expect(me.card_accounts.map(&:card)).to match_array selected_cards
      end

      it "redirects me to... somewhere"
    end
  end # selecting some cards

  describe "submitting the form without selecting any cards" do
    it "doesn't assign any cards to any account" do
      expect{submit_form}.not_to change{CardAccount.count}
    end

    it "redirects me to... somewhere"
  end
end
