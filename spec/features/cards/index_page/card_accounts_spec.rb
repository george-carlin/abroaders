require 'rails_helper'

RSpec.describe 'cards index page - "card accounts" section' do
  include ApplicationSurveyMacros

  subject { page }

  let(:account)   { create(:account, :couples, :eligible, :onboarded) }
  let(:owner)     { account.owner }
  let(:companion) { account.companion }

  before { login_as_account(account) }

  before(:all)   { @products = create_list(:card_product, 2) }
  let(:products) { @products }

  def create_card(person, product)
    run!(
      CardAccount::Create,
      {
        product_id: product.id,
        card: { opened_on: Date.parse('2017-01-01'), person_id: person.id },
      },
      'account' => account,
    )['model']
  end

  # basic smoke test that the cards are being rendered; for more detail
  # see the tests for Card::Cell::Index::CardAccounts
  it '' do
    o_card = create_card(owner, products[0])
    c_card = create_card(companion, products[1])

    visit cards_path

    expect(page).to have_selector("#owner_card_accounts ##{dom_id(o_card)}")
    expect(page).to have_selector("#companion_card_accounts ##{dom_id(c_card)}")
  end

  example 'deleting a card', :js do
    card = create_card(owner, products[0])
    visit cards_path
    click_link 'Delete'
    expect(page).to have_success_message 'Removed card'
    expect(Card.exists?(id: card.id)).to be false
  end
end
