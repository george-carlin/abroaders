require "rails_helper"

describe "card accounts edit page", :js do
  let(:bank) { create(:bank, name: "Chase") }
  let(:account) { create(:account, :onboarded) }
  let(:me) { account.owner }
  let(:product) { create(:card_product, :business, :visa, bank_id: bank.id, name: "Card 0") }
  let(:submit_form) { click_button "Submit" }

  def end_of_month(year, month)
    Date.parse("#{year}-#{month}-01").end_of_month.strftime("%F")
  end

  describe "opened card" do
    let(:card_account) { create(:card_account, :open, product: product, person: me) }
    let(:this_year) { Date.today.year.to_s }
    let(:last_year) { (Date.today.year - 1).to_s }

    before do
      login_as(account)
      visit edit_card_account_path(card_account)
    end

    example "initial page layout" do
      expect(page).to have_content "Edit Card"
      expect(page).to have_selector "#edit_card_account_#{card_account.id}"
      expect(page).to have_button "Submit"
    end

    it "initially has no inputs for closed dates" do
      expect(page).to have_no_selector("#card_account_closed_year")
      expect(page).to have_no_selector("#card_account_closed_month")
    end

    describe "filling fields" do
      before do
        select "Jan",     from: :card_account_opened_month
        select this_year, from: :card_account_opened_year
      end

      describe "and submitting the form" do
        describe "the updated cards" do
          before do
            submit_form
            card_account.reload
          end

          specify "have the given opened and closed dates" do
            expect(card_account.opened_at.strftime("%F")).to eq end_of_month(this_year, "01")
            expect(card_account.closed_at).to be_nil
          end

          specify "have the right statuses" do
            expect(card_account.status).to eq "open"
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
        select "Jan",     from: :card_account_opened_month
        select this_year, from: :card_account_opened_year
        check "card_account_closed"
        select "Apr",     from: :card_account_closed_month
        select last_year, from: :card_account_closed_year
      end

      describe "and submitting the form" do
        describe "the updated cards" do
          before do
            submit_form
            card_account.reload
          end

          specify "have the given opened and closed dates" do
            expect(card_account.opened_at.strftime("%F")).to eq end_of_month(this_year, "01")
            expect(card_account.closed_at.strftime("%F")).to eq end_of_month(last_year, "04")
          end

          specify "have the right statuses" do
            expect(card_account.status).to eq "closed"
          end
        end

        it "takes me to the cards path" do
          submit_form
          expect(current_path).to eq card_accounts_path
        end
      end
    end
  end

  describe "closed cards" do
    let(:card_account) { create(:card_account, :closed, product: product, person: me) }
    let(:this_year) { Date.today.year.to_s }
    let(:last_year) { (Date.today.year - 1).to_s }

    before do
      login_as(account)
      visit edit_card_account_path(card_account)
    end

    example "initial page layout" do
      expect(page).to have_content "Edit Card"
      expect(page).to have_selector "#edit_card_account_#{card_account.id}"
      expect(page).to have_button "Submit"
    end

    it "initially has inputs for closed dates" do
      expect(page).to have_selector("#card_account_closed_year")
      expect(page).to have_selector("#card_account_closed_month")
    end

    describe "filling fields" do
      before do
        select "Jan",     from: :card_account_opened_month
        select this_year, from: :card_account_opened_year
        select "Apr",     from: :card_account_closed_month
        select last_year, from: :card_account_closed_year
      end

      describe "and submitting the form" do
        describe "the updated cards" do
          before do
            submit_form
            card_account.reload
          end

          specify "have the given opened and closed dates" do
            expect(card_account.opened_at.strftime("%F")).to eq end_of_month(this_year, "01")
            expect(card_account.closed_at.strftime("%F")).to eq end_of_month(last_year, "04")
          end

          specify "have the right statuses" do
            expect(card_account.status).to eq "closed"
          end
        end

        it "takes me to the cards path" do
          submit_form
          expect(current_path).to eq card_accounts_path
        end
      end
    end

    describe "make it opened" do
      before do
        select "Jan",     from: :card_account_opened_month
        select this_year, from: :card_account_opened_year
        uncheck "card_account_closed"
      end

      describe "and submitting the form" do
        describe "the updated cards" do
          before do
            submit_form
            card_account.reload
          end

          specify "have the given opened and closed dates" do
            expect(card_account.opened_at.strftime("%F")).to eq end_of_month(this_year, "01")
            expect(card_account.closed_at).to be_nil
          end

          specify "have the right statuses" do
            expect(card_account.status).to eq "open"
          end
        end

        it "takes me to the cards path" do
          submit_form
          expect(current_path).to eq card_accounts_path
        end
      end
    end
  end
end
