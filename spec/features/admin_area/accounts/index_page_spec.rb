require "rails_helper"

RSpec.describe "admin section" do
  describe "account pages index page", :js, :manual_clean do
    subject { page }

    include_context "logged in as admin"

    before(:all) do
      @accounts = [
        create(:account, email: 'A@example.com'),
        create(:account, email: 'B@example.com'),
        create(:account, email: 'C@example.com'),
        create(:account, email: 'D@example.com'),
      ]
    end

    before do
      @real_accounts_per_page = AdminArea::Account::Cell::Index.config.accounts_per_page
      AdminArea::Account::Cell::Index.config.accounts_per_page = 2
      visit admin_accounts_path
    end
    after { AdminArea::Account::Cell::Index.config.accounts_per_page = @real_accounts_per_page }

    example 'pagination' do
      @accounts[0..1].each { |acc| expect(page).to have_account(acc) }
      @accounts[2..3].each { |acc| expect(page).to have_no_account(acc) }
      click_link '2'
      @accounts[0..1].each { |acc| expect(page).to have_no_account(acc) }
      @accounts[2..3].each { |acc| expect(page).to have_account(acc) }
    end

    def have_account(account)
      have_selector account_selector(account)
    end

    def have_no_account(account)
      have_no_selector account_selector(account)
    end

    def account_selector(account)
      "##{dom_id(account)}"
    end
  end
end
