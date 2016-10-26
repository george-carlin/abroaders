require 'rails_helper'

describe 'balances pages' do
  include_context 'logged in'
  let(:owner) { account.owner }

  before(:all) { @currencies = create_list(:currency, 2) }
  let(:currencies) { @currencies }

  describe "index page" do
    example "viewing my balances" do
      balance_0 = owner.balances.create!(currency: currencies[0], value: 1234)
      balance_1 = owner.balances.create!(currency: currencies[1], value: 2468)
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
      balance = owner.balances.create!(currency: currencies[0], value: 1234)
      balance_on_page = BalanceOnPage.new(balance, self)

      visit balances_path

      balance_on_page.update_value_to(2345)

      balance.reload
      expect(balance.value).to eq 2345
    end

    example "trying to update a balance invalidly", :js, :manual_clean do
      balance = owner.balances.create!(currency: currencies[0], value: 1234)
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
