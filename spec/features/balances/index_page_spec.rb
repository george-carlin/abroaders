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

      within_balance(balance_0) do
        expect(page).to have_content "1,234"
        expect(page).to have_content currencies[0].name
      end

      within_balance(balance_1) do
        expect(page).to have_content "2,468"
        expect(page).to have_content currencies[1].name
      end
    end

    example "updating a balance", :js, :manual_clean do
      balance = owner.balances.create!(currency: currencies[0], value: 1234)
      visit balances_path
      update_balance_value(balance, 2345)
      balance.reload
      expect(balance.value).to eq 2345
    end

    example "trying to update a balance invalidly", :js, :manual_clean do
      balance = owner.balances.create!(currency: currencies[0], value: 1234)
      visit balances_path

      expect do
        update_balance_value(balance, -2345)
        balance.reload
      end.not_to change { balance.value }

      expect(page).to have_content "Invalid value"
    end
  end

  def balance_selector(balance)
    "##{dom_id(balance)}"
  end

  def within_balance(balance, &block)
    within(balance_selector(balance), &block)
  end

  def update_balance_value(balance, new_value)
    within_balance(balance) do
      click_button 'Edit'
      fill_in :balance_value, with: new_value
      click_button 'Save'
      wait_for_ajax
    end
  end
end
