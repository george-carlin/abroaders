require 'rails_helper'

RSpec.describe 'admin area - edit card account page', :js do
  include_context 'logged in as admin'

  let(:account) { create(:account, :onboarded) }
  let(:person)  { account.owner }
  let(:product) { create(:card_product) }

  let(:card_account) { create_card_account(person: person) }

  let(:path) { edit_admin_card_account_path(person, card_account) }

  example 'updating card account', :js do
    visit path

    expect(page).to have_field :card_opened_on_1i
    expect(page).to have_field :card_opened_on_2i
    expect(page).to have_field :card_closed, checked: false

    check :card_closed
    click_button 'Save'
    card_account.reload
    expect(card_account).to be_closed
    expect(current_path).to eq admin_person_path(person)
  end

  example 'updating a card account from closed to opened' do
    card_account = create_card_account(:closed, person: person)
    visit path

    expect(page).to have_field :card_closed, checked: true
    uncheck :card_closed
    click_button 'Save'
    card_account.reload
    expect(card_account).to be_open
    expect(current_path).to eq admin_person_path(person)
  end

  example 'invalid card update' do
    visit path

    check :card_closed
    # closed before opened:
    select (Date.today.year - 1).to_s, from: :card_closed_on_1i
    click_button 'Save'

    expect(card_account.reload.closed_on).to be_nil

    # still shows form, including with the 'closed' inputs visible:
    expect(page).to have_field :card_opened_on_1i
    expect(page).to have_field :card_opened_on_2i
    expect(page).to have_field :card_closed, checked: true
    expect(page).to have_field :card_closed_on_1i
    expect(page).to have_field :card_closed_on_2i
  end
end
