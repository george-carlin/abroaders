require 'rails_helper'

RSpec.describe 'card accounts edit page', :js do
  let(:bank)    { create(:bank, name: 'Chase') }
  let(:account) { create(:account, :onboarded) }
  let(:person)  { account.owner }
  let(:product) { create(:card_product, :business, :visa, bank_id: bank.id, name: 'Card 0') }
  let(:submit_form) { click_button 'Save' }

  before { login_as(account) }

  let(:opened_card) { create(:card, :open,   product: product, person: person) }
  let(:closed_card) { create(:card, :closed, product: product, person: person) }

  example 'opened card has "closed at" hidden by default' do
    visit edit_card_path(opened_card)

    expect(page).to have_no_selector('#card_closed_on_1i')
    expect(page).to have_no_selector('#card_closed_on_2i')
    check :card_closed
    expect(page).to have_selector('#card_closed_on_1i')
    expect(page).to have_selector('#card_closed_on_2i')
    uncheck :card_closed
    expect(page).to have_no_selector('#card_closed_on_1i')
    expect(page).to have_no_selector('#card_closed_on_2i')
  end

  example 'closed card has "closed at" visible by default' do
    visit edit_card_path(closed_card)

    expect(page).to have_selector('#card_closed_on_1i')
    expect(page).to have_selector('#card_closed_on_2i')
    uncheck :card_closed
    expect(page).to have_no_selector('#card_closed_on_1i')
    expect(page).to have_no_selector('#card_closed_on_2i')
    check :card_closed
    expect(page).to have_selector('#card_closed_on_1i')
    expect(page).to have_selector('#card_closed_on_2i')
  end

  example 'valid update' do
    visit edit_card_path(opened_card)
    check :card_closed
    submit_form
    expect(opened_card.reload.closed_on).to be_present
    expect(current_path).to eq cards_path
  end

  example 'unclosing a closed card' do
    visit edit_card_path(closed_card)
    uncheck :card_closed
    submit_form
    expect(closed_card.reload.closed_on).to be nil
    expect(current_path).to eq cards_path
  end

  example 'invalid update' do
    visit edit_card_path(opened_card)
    check :card_closed
    closed = 5.years.ago
    raise unless closed < opened_card.opened_on # make sure it will actually fail
    select closed.year, from: :card_closed_on_1i
    select Date::MONTHNAMES[closed.month][0..2], from: :card_closed_on_2i
    submit_form
    expect(opened_card.reload.closed_on).not_to be_present
    expect(page).to have_error_message
    expect(current_path).to eq card_path(opened_card) # POST /cards/:id
  end
end
