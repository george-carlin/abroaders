require "rails_helper"

describe "card accounts survey", :onboarding do
  subject { page }

  let!(:account) do
    create(:account, monthly_spending_usd: chosen_type ? 1000 : nil)
  end
  let!(:me) { account.people.first }

  before do
    create(:spending_info, person: me) if onboarded_spending
    me.update_attributes!(onboarded_cards: onboarded_cards)
    eligible ?  me.eligible_to_apply! : me.ineligible_to_apply!
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

    # Sanity checks:
    raise unless chosen_type == account.onboarded_account_type?
    raise unless eligible == me.eligible_to_apply?
    raise unless onboarded_cards == me.onboarded_cards?
    raise unless onboarded_spending == me.onboarded_spending?
    visit survey_person_card_accounts_path(me)
  end

  let(:chosen_type) { true }
  let(:eligible)    { true }
  let(:onboarded_cards) { false }
  let(:onboarded_spending) { true }

  let(:submit_form) { click_button "Save" }

  def card_checkbox(card)
    :"card_account_card_ids_#{card.id}"
  end

  shared_examples "submitting the form" do
    it "takes me to the balances survey" do
      submit_form
      expect(current_path).to eq survey_person_balances_path(me)
    end

    it "marks this person as having completed the cards survey" do
      submit_form
      expect(me.reload.onboarded_cards?).to be true
    end
  end

  context "when I haven't chosen an account type yet" do
    let(:chosen_type) { false }
    it "redirects me to the accounts type survey" do
      expect(current_path).to eq type_account_path
    end
  end

  context "when I'm not eligible to apply for cards" do
    let(:eligible) { false }
    it "redirects me to my balances survey" do
      expect(current_path).to eq survey_person_balances_path(me)
    end
  end

  context "when I need to complete the spending survey" do
    let(:onboarded_spending) { false }
    it "redirects me to the spending survey" do
      expect(current_path).to eq new_person_spending_info_path(me)
    end
  end

  context "when I've already completed this survey" do
    let(:onboarded_cards) { true }
    it "redirects to their balances survey" do
      expect(current_path).to eq survey_person_balances_path(me)
    end
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

      include_examples "submitting the form"
    end
  end # selecting some cards

  describe "submitting the form without selecting any cards" do
    it "doesn't assign any cards to any account" do
      expect{submit_form}.not_to change{CardAccount.count}
    end

    include_examples "submitting the form"
  end
end
