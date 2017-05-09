require 'rails_helper'

RSpec.describe 'new card account page' do
  include_context 'logged in as admin'

  let(:account) { create(:account, :onboarded) }
  let(:person)  { account.owner }
  let!(:product) { create(:card_product) }

  before { visit new_admin_person_card_account_path(person) }

  example 'creating an open card account' do
    expect(page).to have_field :card_account_card_product_id
    expect(page).to have_field :card_account_opened_on_1i
    expect(page).to have_field :card_account_opened_on_2i
    expect(page).to have_field :card_account_closed

    expect do
      click_button 'Save'
    end.to change { person.cards.count }.by(1)

    card_account = person.cards.last
    expect(card_account).to be_opened
    expect(current_path).to eq admin_person_path(person)
  end

  example 'creating a closed card account' do
    check :card_account_closed

    expect do
      click_button 'Save'
    end.to change { person.cards.count }.by(1)

    expect(person.cards.last).to be_closed

    expect(current_path).to eq admin_person_path(person)
  end

  example 'invalid card creation', :js do
    check :card_account_closed
    # closed before opened:
    select (Date.today.year - 1).to_s, from: :card_account_closed_on_1i
    expect do
      click_button 'Save'
    end.not_to change { person.cards.count }

    # still shows form, including with the 'closed' inputs visible:
    expect(page).to have_field :card_account_card_product_id
    expect(page).to have_field :card_account_opened_on_1i
    expect(page).to have_field :card_account_opened_on_2i
    expect(page).to have_field :card_account_closed, checked: true
    expect(page).to have_field :card_account_closed_on_1i
    expect(page).to have_field :card_account_closed_on_2i
  end
end
