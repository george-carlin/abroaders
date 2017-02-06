require "rails_helper"

RSpec.describe "card accounts page survey cards section" do
  include ApplicationSurveyMacros

  subject { page }

  include_context "logged in"

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

  let(:have_survey_cards_header)    { have_selector "h2", text: "Other Cards" }
  let(:have_no_survey_cards_header) { have_no_selector "h2", text: "Other Cards" }

  let(:survey_cards_section)           { "#cards_from_survey" }
  let(:owner_survey_cards_section)     { "#owner_cards_from_survey" }
  let(:companion_survey_cards_section) { "#companion_cards_from_survey" }

  example "no companion; I have 'from survey' cards" do
    open_acc   = create(:open_survey_card,   person: person, product: products[0])
    closed_acc = create(:closed_survey_card, person: person, product: products[1])

    visit_page

    # has a section for them:
    expect(page).to have_survey_cards_header
    expect(page).to have_selector owner_survey_cards_section

    # lists them and their info:
    within owner_survey_cards_section do
      expect(page).to have_selector card_selector(open_acc)
      expect(page).to have_selector card_selector(closed_acc)
    end

    expect(page).to have_no_selector "h2", text: "#{person.first_name}'s cards"
  end

  example "companion; only owner has survey cards" do
    create_companion!

    open_acc   = create(:open_survey_card,   person: person, product: products[0])
    closed_acc = create(:closed_survey_card, person: person, product: products[1])

    visit_page

    # lists them and their info:
    within owner_survey_cards_section do
      expect(page).to have_selector card_selector(open_acc)
      expect(page).to have_selector card_selector(closed_acc)
    end

    expect(page).to have_selector "h3", text: "#{companion.first_name}'s Cards"
    expect(page).to have_content "#{companion.first_name} has no other cards"
  end

  example "companion; only companion has survey cards" do
    create_companion!
    open_acc   = create(:open_survey_card, person: companion, product: products[0])
    closed_acc = create(:closed_survey_card, person: companion, product: products[1])

    visit_page

    expect(page).to have_selector "h3", text: "#{companion.first_name}'s Cards"

    within companion_survey_cards_section do
      expect(page).to have_selector card_selector(open_acc)
      expect(page).to have_selector card_selector(closed_acc)
    end

    expect(page).to have_selector "h3", text: "#{person.first_name}'s Cards"
    expect(page).to have_content "#{person.first_name} has no other cards"
  end

  example "companion; both people have survey cards" do
    o_open   = create(:open_survey_card,   person: person, product: products[0])
    o_closed = create(:closed_survey_card, person: person, product: products[1])
    create_companion!
    c_open   = create(:open_survey_card,   person: companion, product: products[0])
    c_closed = create(:closed_survey_card, person: companion, product: products[1])

    visit_page

    within owner_survey_cards_section do
      expect(page).to have_selector card_selector(o_open)
      expect(page).to have_selector card_selector(o_closed)
    end

    within companion_survey_cards_section do
      expect(page).to have_selector card_selector(c_open)
      expect(page).to have_selector card_selector(c_closed)
    end
  end
end
