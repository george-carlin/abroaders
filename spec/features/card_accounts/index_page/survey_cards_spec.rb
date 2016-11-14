require "rails_helper"

describe "card accounts page survey cards section" do
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
    visit card_accounts_path
  end

  def create_companion!
    create(:person, owner: false, account: account)
    account.reload
  end

  let(:have_survey_cards_header)    { have_selector "h2", text: "Other Cards" }
  let(:have_no_survey_cards_header) { have_no_selector "h2", text: "Other Cards" }

  let(:survey_cards_section)           { "#card_accounts_from_survey" }
  let(:owner_survey_cards_section)     { "#owner_card_accounts_from_survey" }
  let(:companion_survey_cards_section) { "#companion_card_accounts_from_survey" }

  example "no companion and no 'from survey' cards" do
    visit_page
    # it has no 'Other cards' section
    expect(page).to have_no_survey_cards_header
    expect(page).to have_no_selector survey_cards_section
    expect(page).to have_no_content "has no other cards"
  end

  example "no companion; I have 'from survey' cards" do
    open_acc   = create(:open_survey_card_account,   person: person, product: products[0])
    closed_acc = create(:closed_survey_card_account, person: person, product: products[1])

    open_acc_on_page   = CardAccountOnPage.new(open_acc, self)
    closed_acc_on_page = CardAccountOnPage.new(closed_acc, self)

    visit_page

    # has a section for them:
    expect(page).to have_survey_cards_header
    expect(page).to have_selector owner_survey_cards_section

    # lists them and their info:
    within owner_survey_cards_section do
      expect(open_acc_on_page).to be_present
      expect(closed_acc_on_page).to be_present
    end

    expect(open_acc_on_page).to have_info_for_a_survey_card
    expect(closed_acc_on_page).to have_info_for_a_survey_card

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

    open_acc   = create(:open_survey_card_account,   person: person, product: products[0])
    closed_acc = create(:closed_survey_card_account, person: person, product: products[1])

    open_acc_on_page   = CardAccountOnPage.new(open_acc, self)
    closed_acc_on_page = CardAccountOnPage.new(closed_acc, self)

    visit_page

    # lists them and their info:
    within owner_survey_cards_section do
      expect(open_acc_on_page).to be_present
      expect(closed_acc_on_page).to be_present
    end

    expect(page).to have_selector "h3", text: "#{companion.first_name}'s Cards"
    expect(page).to have_content "#{companion.first_name} has no other cards"
  end

  example "companion; only companion has survey cards" do
    create_companion!
    open_acc   = create(:open_survey_card_account, person: companion, product: products[0])
    closed_acc = create(:closed_survey_card_account, person: companion, product: products[1])

    open_acc_on_page   = CardAccountOnPage.new(open_acc, self)
    closed_acc_on_page = CardAccountOnPage.new(closed_acc, self)

    visit_page

    expect(page).to have_selector "h3", text: "#{companion.first_name}'s Cards"
    within companion_survey_cards_section do
      expect(open_acc_on_page).to be_present
      expect(closed_acc_on_page).to be_present
    end

    expect(open_acc_on_page).to have_info_for_a_survey_card
    expect(closed_acc_on_page).to have_info_for_a_survey_card

    expect(page).to have_selector "h3", text: "#{person.first_name}'s Cards"
    expect(page).to have_content "#{person.first_name} has no other cards"
  end

  example "companion; both people have survey cards" do
    m_open   = create(:open_survey_card_account,   person: person, product: products[0])
    m_closed = create(:closed_survey_card_account, person: person, product: products[1])
    create_companion!
    p_open   = create(:open_survey_card_account,   person: companion, product: products[0])
    p_closed = create(:closed_survey_card_account, person: companion, product: products[1])

    m_open   = CardAccountOnPage.new(m_open,   self)
    m_closed = CardAccountOnPage.new(m_closed, self)
    p_open   = CardAccountOnPage.new(p_open,   self)
    p_closed = CardAccountOnPage.new(p_closed, self)

    visit_page

    within owner_survey_cards_section do
      expect(m_open).to be_present
      expect(m_closed).to be_present
    end

    within companion_survey_cards_section do
      expect(p_open).to be_present
      expect(p_closed).to be_present
    end

    expect(m_open).to have_info_for_a_survey_card
    expect(m_closed).to have_info_for_a_survey_card
    expect(p_open).to have_info_for_a_survey_card
    expect(p_closed).to have_info_for_a_survey_card
  end
end
