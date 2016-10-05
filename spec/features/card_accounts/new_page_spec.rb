require "rails_helper"

describe "card accounts new page", :js do

  let(:bank) { Bank.find_by(name: "Chase") }
  let(:card) { create(:card, :business, :visa, bank_id: bank.id, name: "Card 0") }
  let(:submit_form) { click_button "Submit" }

  def card_on_page(card)
    CardOnNewPage.new(card, self)
  end

  def end_of_month(year, month)
    Date.parse("#{year}-#{month}-01").end_of_month.strftime("%F")
  end

  shared_examples "submitting the form with closed date" do
    specify "have the given opened and closed dates" do
      submit_form
      expect(new_card_account.opened_at.strftime("%F")).to eq end_of_month(this_year, "01")
      expect(new_card_account.closed_at.strftime("%F")).to eq end_of_month(last_year, "04")
    end

    specify "have the right statuses" do
      submit_form
      expect(new_card_account.status).to eq "closed"
    end

    it "takes me to the cards path" do
      submit_form
      expect(current_path).to eq card_accounts_path
    end
  end

  shared_examples "submitting the form without closed date" do
    specify "have the given opened and closed dates" do
      submit_form
      expect(new_card_account.opened_at.strftime("%F")).to eq end_of_month(this_year, "01")
      expect(new_card_account.closed_at).to be_nil
    end

    specify "have the right statuses" do
      submit_form
      expect(new_card_account.status).to eq "open"
    end

    it "takes me to the cards path" do
      submit_form
      expect(current_path).to eq card_accounts_path
    end
  end

  let(:this_year) { Date.today.year.to_s }
  let(:last_year) { (Date.today.year - 1).to_s }
  let(:page_card) { card_on_page(card) }
  let(:new_card_account) { CardAccount.last }

  context "when account is ineligible" do
    let(:account) { create(:account, :onboarded) }

    it "redirect to dashboard" do
      account.owner.update!(eligible: false)
      login_as(account)
      visit new_card_card_account_path(card)
      expect(current_path).to eq root_path
    end
  end

  context "when account is eligible" do
    before do
      login_as(account)
      visit new_card_card_account_path(card)
    end

    context "and hasn't companion" do
      let(:account) { create(:account, :onboarded) }

      example "initial page layout" do
        expect(page).to have_content "Add New Card"
        expect(page).to have_selector "#new_card_card_account"
        expect(page).to have_button "Submit"
      end

      it "initially has no inputs for closed dates" do
        expect(page).to have_no_selector("#card_card_account_closed_year")
        expect(page).to have_no_selector("#card_card_account_closed_month")
      end

      it "has no select tag for person" do
        expect(page).to have_no_selector("#card_card_account_person_id")
      end

      describe "filling fields" do
        before do
          select "Jan",     from: page_card.opened_at_month
          select this_year, from: page_card.opened_at_year
        end

        it "has owner as card holder" do
          submit_form
          expect(new_card_account.person).to eq account.owner
        end

        include_examples "submitting the form without closed date"
      end

      describe "make it closed" do
        before do
          select "Jan",     from: page_card.opened_at_month
          select this_year, from: page_card.opened_at_year
          check "card_card_account_closed"
          select "Apr",     from: page_card.closed_at_month
          select last_year, from: page_card.closed_at_year
        end

        include_examples "submitting the form with closed date"
      end
    end

    context "and has companion" do
      let(:account) { create(:account, :with_companion, :onboarded) }

      example "initial page layout" do
        expect(page).to have_content "Add New Card"
        expect(page).to have_selector "#new_card_card_account"
        expect(page).to have_button "Submit"
      end

      it "initially has no inputs for closed dates" do
        expect(page).to have_no_selector("#card_card_account_closed_year")
        expect(page).to have_no_selector("#card_card_account_closed_month")
      end

      it "has select tag for person" do
        expect(page).to have_selector("#card_card_account_person_id")
      end

      describe "filling fields" do
        before do
          select "Jan",     from: page_card.opened_at_month
          select this_year, from: page_card.opened_at_year
        end

        example "selecting owner as card holder" do
          select account.owner.first_name, from: page_card.person_id
          submit_form
          expect(new_card_account.person).to eq account.owner
        end

        example "selecting companion as card holder" do
          select account.companion.first_name, from: page_card.person_id
          submit_form
          expect(new_card_account.person).to eq account.companion
        end

        include_examples "submitting the form without closed date"
      end

      describe "make it closed" do
        before do
          select "Jan",     from: page_card.opened_at_month
          select this_year, from: page_card.opened_at_year
          check "card_card_account_closed"
          select "Apr",     from: page_card.closed_at_month
          select last_year, from: page_card.closed_at_year
        end

        include_examples "submitting the form with closed date"
      end
    end
  end
end
