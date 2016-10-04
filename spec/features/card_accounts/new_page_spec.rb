require "rails_helper"

describe "card accounts new page", :js do

  let(:bank) { Bank.find_by(name: "Chase") }
  let(:account) { create(:account, :onboarded) }
  let(:me) { account.owner }
  let(:card) { create(:card, :business, :visa, bank_id: bank.id, name: "Card 0") }
  let(:submit_form) { click_button "Submit" }

  def card_on_page(card)
    CardOnNewPage.new(card, self)
  end

  def end_of_month(year, month)
    Date.parse("#{year}-#{month}-01").end_of_month.strftime("%F")
  end

  let(:this_year) { Date.today.year.to_s }
  let(:last_year) { (Date.today.year - 1).to_s }
  let(:page_card) { card_on_page(card) }
  let(:new_card_account) { CardAccount.last }

  before do
    login_as(account)
    visit new_card_card_account_path(card)
  end

  example "initial page layout" do
    expect(page).to have_content "Add New Card"
    expect(page).to have_selector "#new_card_card_account"
    expect(page).to have_button "Submit"
  end

  it "initially has no inputs for closed dates" do
    expect(page).to have_no_selector("#card_account_closed_year")
    expect(page).to have_no_selector("#card_account_closed_month")
  end

  describe "filling fields" do
    before do
      select "Jan",     from: page_card.opened_at_month
      select this_year, from: page_card.opened_at_year
    end

    describe "and submitting the form" do
      describe "the created card accounts" do
        before do
          submit_form
        end

        specify "have the given opened and closed dates" do
          expect(new_card_account.opened_at.strftime("%F")).to eq end_of_month(this_year, "01")
          expect(new_card_account.closed_at).to be_nil
        end

        specify "have the right statuses" do
          expect(new_card_account.status).to eq "open"
        end
      end

      it "takes me to the cards path" do
        submit_form
        expect(current_path).to eq card_accounts_path
      end
    end
  end

  describe "make it closed" do
    before do
      select "Jan",     from: page_card.opened_at_month
      select this_year, from: page_card.opened_at_year
      check "card_card_account_closed"
      select "Apr",     from: page_card.closed_at_month
      select last_year, from: page_card.closed_at_year
    end

    describe "and submitting the form" do
      describe "the c card accounts" do
        before do
          submit_form
        end

        specify "have the given opened and closed dates" do
          expect(new_card_account.opened_at.strftime("%F")).to eq end_of_month(this_year, "01")
          expect(new_card_account.closed_at.strftime("%F")).to eq end_of_month(last_year, "04")
        end

        specify "have the right statuses" do
          expect(new_card_account.status).to eq "closed"
        end
      end

      it "takes me to the cards path" do
        submit_form
        expect(current_path).to eq card_accounts_path
      end
    end
  end
end
