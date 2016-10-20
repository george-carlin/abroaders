require 'rails_helper'

describe "balances pages" do
  include_context "logged in"
  let(:me) { account.owner }

  before(:all) { @currencies = create_list(:currency, 2) }
  let(:currencies) { @currencies }

  describe "new page" do
    before { visit new_person_balance_path(me) }

    example "creating a new balance" do
      select currencies[1].name, from: :balance_currency_id
      fill_in :balance_value, with: 23_45

      # it creates a balance:
      expect do
        click_button "Create Balance"
      end.to change { me.balances.count }.by(1)

      # it has the right values:
      balance = me.balances.last
      expect(balance.currency).to eq currencies[1]
      expect(balance.value).to eq 23_45
    end

    example "submitting a balance without a value" do
      select currencies[1].name, from: :balance_currency_id
      # it doesn't create a balance:
      expect { click_button "Create Balance" }.not_to change { me.balances.count }
    end
  end

  describe "index page" do
    example "viewing my balances" do
      balance_0 = me.balances.create!(currency: currencies[0], value: 1234)
      balance_1 = me.balances.create!(currency: currencies[1], value: 2468)
      visit balances_path

      balance_0_on_page = BalanceOnPage.new(balance_0, self)
      balance_1_on_page = BalanceOnPage.new(balance_1, self)

      expect(balance_0_on_page).to be_present
      expect(balance_0_on_page).to have_content "1,234"
      expect(balance_0_on_page).to have_content currencies[0].name

      expect(balance_1_on_page).to be_present
      expect(balance_1_on_page).to have_content "2,468"
      expect(balance_1_on_page).to have_content currencies[1].name
    end

    example "updating a balance", :js, :manual_clean do
      balance = me.balances.create!(currency: currencies[0], value: 1234)
      balance_on_page = BalanceOnPage.new(balance, self)

      visit balances_path

      balance_on_page.update_value_to(2345)

      balance.reload
      expect(balance.value).to eq 2345
    end

    example "trying to update a balance invalidly", :js, :manual_clean do
      balance = me.balances.create!(currency: currencies[0], value: 1234)
      balance_on_page = BalanceOnPage.new(balance, self)

      visit balances_path

      expect do
        balance_on_page.update_value_to(-2345)
        balance.reload
      end.not_to change { balance.value }

      expect(page).to have_content "Invalid value"
    end
  end
end
