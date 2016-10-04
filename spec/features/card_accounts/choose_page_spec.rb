require "rails_helper"

describe "card accounts choose page", :onboarding, :js, :manual_clean  do
  subject { page }

  before(:all) do
    chase = Bank.find_by(name: "Chase")
    citi  = Bank.find_by(name: "Citibank")
    @banks = [chase, citi]
    @visible_cards = [
      create(:card, :business, :visa,       bank_id: chase.id, name: "Card 0"),
      create(:card, :personal, :mastercard, bank_id: chase.id, name: "Card 1"),
      create(:card, :business, :mastercard, bank_id: citi.id,  name: "Card 2"),
      create(:card, :personal, :visa,       bank_id: citi.id,  name: "Card 3"),
      create(:card, :personal, :visa,       bank_id: citi.id,  name: "Card 4"),
    ]
  end

  before do
    login_as account.reload
    visit choose_card_card_accounts_path
  end

  let(:account) { create(:account, :onboarded)}
  let(:submit_form) { click_button "Submit" }

  def card_on_page(card)
    CardOnSurveyPage.new(card, self)
  end

  def end_of_month(year, month)
    Date.parse("#{year}-#{month}-01").end_of_month.strftime("%F")
  end

  def expand_banks
    @banks.each do |bank|
      click_on bank.name.upcase
      sleep 0.5
    end
  end

  example "initial page layout" do
    expect(page).to have_selector "#menu"
    expect(page).to have_no_button "Yes"
    expect(page).to have_no_button "No"
    # doesn't initially list cards:
    expect(page).to have_no_selector ".card-survey-checkbox"
  end

  example "clicking Back redirect to card page page" do
    click_on "Back"
    expect(current_path).to eq card_accounts_path
  end

  describe "expand banks" do
    before { expand_banks }

    it "shows cards grouped by bank, then B/P" do
      @banks.each do |bank|
        expect(page).to have_selector "h2", text: bank.name.upcase
        within "#bank-collapse-#{bank.id}" do
          %w[personal business].each do |type|
            expect(page).to have_selector "h4", text: "#{type.capitalize} Cards"
            expect(page).to have_selector "##{bank.to_param}_cards"
            expect(page).to have_selector "##{bank.to_param}_#{type}_cards"
          end
        end
      end
    end

    it "only has one 'group' per bank and b/p" do # bug fix
      @banks.each do |bank|
        within "#bank-collapse-#{bank.id}" do
          expect(all("[id='#{bank.to_param}_cards']").length).to eq 1
          expect(all("[id='#{bank.to_param}_personal_cards']").length).to eq 1
          expect(all("[id='#{bank.to_param}_business_cards']").length).to eq 1
        end
      end
    end

    it "initially has no inputs for opened/closed dates" do
      def test(s); expect(page).to have_no_selector(s); end
      test ".cards_survey_card_account_opened_at_month"
      test ".cards_survey_card_account_opened_at_year"
      test ".cards_survey_card_account_closed"
      test ".cards_survey_card_account_closed_at_month"
      test ".cards_survey_card_account_closed_at_year"
    end

    describe "a business card's displayed name" do
      it "follows the format 'card name, BUSINESS, network'" do
        within "#card-#{@visible_cards[0].id}" do
          expect(page).to have_content "Card 0 business Visa"
        end
        within "#card-#{@visible_cards[2].id}" do
          expect(page).to have_content "Card 2 business MasterCard"
        end
      end
    end

    describe "a personal card's displayed name" do
      it "follows the format 'card name, network'" do
        within "#card-#{@visible_cards[1].id}" do
          expect(page).to have_content "Card 1 MasterCard"
        end
        within "#card-#{@visible_cards[3].id}" do
          expect(page).to have_content "Card 3 Visa"
        end
      end
    end

    describe "clicking on a card" do
      it "open new card account page" do
        click_on "new-card-link-#{@visible_cards[0].id}"
        expect(current_path).to eq new_card_card_account_path(@visible_cards[0])
      end
    end
  end
end
