require 'rails_helper'

RSpec.describe 'new balance page' do
  let(:account) { create_account(:onboarded) }
  let(:owner) { account.owner }

  before(:all) { @currencies = Array.new(2) { create_currency } }
  let(:currencies) { @currencies }

  before do
    login_as(account)
    visit new_balance_path
  end

  example 'page layout and form' do
    expect(page).to have_field :balance_currency_id
    expect(page).to have_no_field :balance_person_id
    expect(page).to have_field :balance_value
    expect(page).to have_button 'Save'
  end

  example 'creating a new balance' do
    select currencies[1].name, from: :balance_currency_id
    fill_in :balance_value, with: 2345

    # it creates a balance:
    expect do
      click_button 'Save'
    end.to change { owner.balances.count }.by(1)

    # it has the right values:
    balance = owner.balances.last
    expect(balance.currency).to eq currencies[1]
    expect(balance.value).to eq 23_45
  end

  example 'submitting a balance without a value' do
    select currencies[1].name, from: :balance_currency_id
    # it doesn't create a balance:
    expect { click_button 'Save' }.not_to change { owner.balances.count }
    expect(page).to have_error_message
  end

  example 'submitting a balance with a negative value' do
    fill_in :balance_value, with: -1

    expect do
      click_button 'Save'
    end.not_to change { owner.balances.count }

    expect(page).to have_field :balance_value, with: -1 # bug fix
  end

  # TODO what happens if I submit letters?

  describe 'couples account' do
    let(:account) { create_account(:account, :couples, :onboarded) }
    let(:companion) { account.companion }

    example 'page layout and form' do
      expect(page).to have_field :balance_currency_id
      expect(page).to have_field :balance_person_id
      expect(page).to have_field :balance_value
      expect(page).to have_button 'Save'
    end

    example 'creating a new balance for owner' do
      select account.owner.first_name, from: :balance_person_id
      select currencies[1].name, from: :balance_currency_id
      fill_in :balance_value, with: 2345

      # it creates a balance:
      expect do
        click_button 'Save'
      end.to change { owner.balances.count }.by(1)

      # it has the right values:
      balance = owner.balances.last
      expect(balance.currency).to eq currencies[1]
      expect(balance.value).to eq 23_45
    end

    example 'creating a new balance for companion' do
      select account.companion.first_name, from: :balance_person_id
      select currencies[1].name, from: :balance_currency_id
      fill_in :balance_value, with: 2345

      # it creates a balance:
      expect do
        click_button 'Save'
      end.to change { companion.balances.count }.by(1)

      # it has the right values:
      balance = companion.balances.last
      expect(balance.currency).to eq currencies[1]
      expect(balance.value).to eq 23_45
    end
  end
end
