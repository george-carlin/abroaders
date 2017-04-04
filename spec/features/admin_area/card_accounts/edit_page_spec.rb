require 'rails_helper'

RSpec.describe 'admin area - edit card account page' do
  include_context 'logged in as admin'

  let(:account) { create(:account, :onboarded) }
  let(:person)  { account.owner }
  let(:product) { create(:card_product) }

  let(:card) do
    run!(
      CardAccount::Create,
      { card: { opened_on: Date.today }, product_id: product.id },
      'account' => account,
    )['model']
  end

  before { visit edit_admin_card_path(person, card) }

  example 'updating a card', :js do
    expect(page).to have_field :card_opened_on_1i
    expect(page).to have_field :card_opened_on_2i
    expect(page).to have_field :card_closed, checked: false

    check :card_closed

    click_button 'Save'
    card.reload

    expect(card.closed_on).not_to be nil

    expect(current_path).to eq admin_person_path(person)
  end

  example 'invalid card update', :js do
    check :card_closed
    # closed before opened:
    select (Date.today.year - 1).to_s, from: :card_closed_on_1i
    click_button 'Save'

    expect(card.reload.closed_on).to be_nil

    # still shows form, including with the 'closed' inputs visible:
    expect(page).to have_field :card_opened_on_1i
    expect(page).to have_field :card_opened_on_2i
    expect(page).to have_field :card_closed, checked: true
    expect(page).to have_field :card_closed_on_1i
    expect(page).to have_field :card_closed_on_2i
  end
end
