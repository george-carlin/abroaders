require 'rails_helper'

RSpec.describe 'cards index page - "other cards" section' do
  include ApplicationSurveyMacros

  subject { page }

  include_context 'logged in'

  before do
    person.update!(eligible: true)
  end

  let(:person)    { account.owner }
  let(:companion) { account.companion }

  before(:all)   { @products = create_list(:card_product, 2) }
  let(:products) { @products }

  def visit_page
    visit cards_path
  end

  def create_companion!
    create(:person, owner: false, account: account)
    account.reload
  end

  def card_selector(card)
    '#' << dom_id(card)
  end

  let(:other_cards_section)           { '#cards' }
  let(:owner_other_cards_section)     { '#owner_cards' }
  let(:companion_other_cards_section) { '#companion_cards' }

  example "no companion; I have non-recommendation cards" do
    open_acc   = create(:card, :open, person: person, product: products[0])
    closed_acc = create(:card, :closed, person: person, product: products[1])

    visit_page

    # has a section for them:
    expect(page).to have_selector 'h2', text: 'Other Cards'

    expect(page).to have_selector owner_other_cards_section

    # lists them and their info:
    within owner_other_cards_section do
      expect(page).to have_selector card_selector(open_acc)
      expect(page).to have_selector card_selector(closed_acc)
    end

    expect(page).to have_no_selector 'h2', text: "#{person.first_name}'s cards"
  end

  example "companion; only owner has non-recommendation cards" do
    create_companion!

    open_acc   = create(:card, :open, person: person, product: products[0])
    closed_acc = create(:card, :closed, person: person, product: products[1])

    visit_page

    # lists them and their info:
    within owner_other_cards_section do
      expect(page).to have_selector card_selector(open_acc)
      expect(page).to have_selector card_selector(closed_acc)
    end

    expect(page).to have_selector "h3", text: "#{companion.first_name}'s Cards"
    expect(page).to have_content "#{companion.first_name} has no other cards"
  end

  example "companion; only companion has non-recommendation cards" do
    create_companion!
    open_acc   = create(:card, :open, person: companion, product: products[0])
    closed_acc = create(:card, :closed, person: companion, product: products[1])

    visit_page

    expect(page).to have_selector "h3", text: "#{companion.first_name}'s Cards"

    within companion_other_cards_section do
      expect(page).to have_selector card_selector(open_acc)
      expect(page).to have_selector card_selector(closed_acc)
    end

    expect(page).to have_selector "h3", text: "#{person.first_name}'s Cards"
    expect(page).to have_content "#{person.first_name} has no other cards"
  end

  example "companion; both people have non-recommendation cards" do
    o_open   = create(:card, :open, person: person, product: products[0])
    o_closed = create(:card, :closed, person: person, product: products[1])
    create_companion!
    c_open   = create(:card, :open, person: companion, product: products[0])
    c_closed = create(:card, :closed, person: companion, product: products[1])

    visit_page

    within owner_other_cards_section do
      expect(page).to have_selector card_selector(o_open)
      expect(page).to have_selector card_selector(o_closed)
    end

    within companion_other_cards_section do
      expect(page).to have_selector card_selector(c_open)
      expect(page).to have_selector card_selector(c_closed)
    end
  end

  example 'deleting a card', :js do
    card = create(:card, :open, person: person, product: products[0])
    visit_page
    click_link 'Delete'
    expect(page).to have_success_message 'Removed card'
    expect(Card.exists?(id: card.id)).to be false
  end
end
