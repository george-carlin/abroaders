require "rails_helper"

describe "admin section" do
  describe "account pages index page", :js do
    subject { page }

    include_context "logged in as admin"

    before do
      @accounts = [
        # Specify the email addresses so we have something to test the filtering
        # with:
        create(:account, :onboarded, email: "aaaaaa@example.com"),
        create(:account, :onboarded, email: "bbbbbb@example.com"),
        create(:account, :onboarded_companion, email: "ccccccc@example.com"),
        create(:account, email: "ddddddd@example.com")
      ]
      visit admin_accounts_path
    end

    it "lists every account" do
      within "#admin_accounts_table" do
        @accounts.each do |account|
          is_expected.to have_selector account_selector(account)
        end
      end
    end

    describe "for accounts which have added a main passenger" do
      it "lists the passenger's names" do
        @accounts.slice(0,3).each do |account|
          within account_selector(account) do
            is_expected.to have_content(account.main_passenger_full_name)
          end
        end
      end
    end

    describe "for accounts which have added a companion" do
      it "lists the companion's names" do
        account = @accounts[3]
        within account_selector(account) do
          is_expected.to have_content(account.companion_full_name)
        end
      end
    end

    it "can be sorted"

    describe "typing something into the 'filter' box" do
      it "filters out accounts who don't match your query" do
        fill_in :admin_accounts_table_filter, with: "aaaaaa"
        should have_account @accounts[0]
        should_not have_account @accounts[1]
        should_not have_account @accounts[2]
      end

      it "is case insensitive" do
        fill_in :admin_accounts_table_filter, with: "AaAAaa"
        should have_account @accounts[0]
        should_not have_account @accounts[1]
        should_not have_account @accounts[2]
      end
    end

    context "when an account" do
      before { skip "needes updating to work with passengers, not accounts" }
      context "has completed the onboarding survey" do
        it "has a link to recommend them a card" do
          is_expected.to have_link "Recommend Card",
            href: new_admin_passenger_card_recommendation_path(@accounts[0])
          is_expected.to have_link "Recommend Card",
            href: new_admin_passenger_card_recommendation_path(@accounts[1])
        end
      end

      context "has not completed the onboarding survey" do
        it "does not have a link to recommend them a card" do
          is_expected.to have_no_link "Recommend Card",
            href: new_admin_account_card_recommendation_path(@accounts[3])
        end
      end
    end

    def have_account(account)
      have_selector account_selector(account)
    end

    def account_selector(account)
      "##{dom_id(account)}"
    end
  end
end
