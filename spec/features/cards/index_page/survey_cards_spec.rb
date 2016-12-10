require "rails_helper"

describe "card accounts page survey cards section" do
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

  # TODO this used to be part of a page object. I would convert it
  # to a matcher that this spec can use, but this doesn't belong in
  # a feature spec anyway. Extract the survey card display to a cell
  # and move the test into there
  def have_info_for_a_survey_card
    has_basic_info = has_content?("Card Name: #{product.name}") &&
                     has_content?("Bank: #{product.bank_name}") &&
                     has_content?("Open") &&
                     has_content?(card.opened_at.strftime("%b %Y")) &&
                     has_no_apply_or_decline_btns?

    if !card.closed_at.nil?
      has_basic_info &&
        has_content?("Closed") &&
        has_content?(card.closed_at.strftime("%b %Y"))
    else
      has_basic_info && has_no_content?("Closed")
    end
  end

  example "no companion and no 'from survey' cards" do
    visit_page
    # it has no 'Other cards' section
    expect(page).to have_no_survey_cards_header
    expect(page).to have_no_selector survey_cards_section
    expect(page).to have_no_content "has no other cards"
  end

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

    within card_selector(open_acc) do
      # expect(page).to have_info_for_a_survey_card
    end
    within card_selector(closed_acc) do
      # expect(page).to have_info_for_a_survey_card
    end

    expect(page).to have_no_selector "h2", text: "#{person.first_name}'s cards"
  end

  example "companion; no-one has survey cards" do
    create_companion!
    visit_page
    expect(page).to have_no_survey_cards_header
    expect(page).to have_no_selector survey_cards_section
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

    within card_selector(open_acc) do
      # expect(page).to have_info_for_a_survey_card
    end
    within card_selector(closed_acc) do
      # expect(page).to have_info_for_a_survey_card
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

    within card_selector(o_open) do
      # expect(page).to have_info_for_a_survey_card
    end
    within card_selector(o_closed) do
      # expect(page).to have_info_for_a_survey_card
    end
    within card_selector(c_open) do
      # expect(page).to have_info_for_a_survey_card
    end
    within card_selector(c_closed) do
      # expect(page).to have_info_for_a_survey_card
    end
  end
end
