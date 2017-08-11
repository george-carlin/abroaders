require 'cells_helper'

RSpec.describe AdminArea::People::Cell::Show do
  let(:account) { Account.new(id: 1, created_at: Time.now) }
  let(:aw_email) { "totallyawesomedude@example.com" }

  let(:person) do
    Person.owner.new(
      id: 5,
      account: account,
      award_wallet_email: aw_email,
      first_name: 'Erik',
    )
  end

  example 'basic information' do
    rendered = cell(person, card_products: []).()
    expect(rendered).to have_content account.created_at.strftime('%D')
    # person's name as the page header
    expect(rendered).to have_selector 'h1', text: 'Erik'
    # award wallet email
    expect(rendered).to have_content "AwardWallet email: #{aw_email}"
    expect(rendered).to have_content 'User has not added their spending info'
    expect(rendered).to have_content 'User has no upcoming travel plans'
    # no recommendation notes yet:
    expect(rendered).to have_no_content 'Recommendation Notes'
  end

  example 'owner/companion links' do
    account.email = 'x@x.com'
    account.password = account.password_confirmation = 'qwerqwer'
    account.save!
    person.save!
    rendered = cell(person, card_products: []).()
    expect(rendered).to have_link 'Erik', href: admin_person_path(person)

    # with companion:
    companion = account.create_companion!(first_name: 'Gabi', eligible: true)
    person.reload
    rendered = cell(person, card_products: []).()
    expect(rendered).to have_link 'Erik', href: admin_person_path(person)
    expect(rendered).to have_link 'Gabi', href: admin_person_path(companion)

    # on companion's page:
    rendered = cell(companion, card_products: []).()
    expect(rendered).to have_link 'Erik', href: admin_person_path(person)
    expect(rendered).to have_link 'Gabi', href: admin_person_path(companion)
  end

  example 'with spending info' do
    person.build_spending_info(
      credit_score: 678,
      has_business: :with_ein,
      business_spending_usd: 1500,
    )
    rendered = cell(person, card_products: []).()
    expect(rendered).not_to have_content 'User has not added their spending info'
    expect(rendered).to have_content 'Credit score: 678'
    expect(rendered).to have_content 'Will apply for loan in next 6 months: No'
    expect(rendered).to have_content 'Business spending: $1,500.00'
    expect(rendered).to have_content '(Has EIN)'
  end

  example 'with travel plans' do
    # Currently users can only create travel plans that are from/to airports.
    # Legacy data will be to/from countries, but don't bother testing that
    # here.

    tp_class = Struct.new(:id)
    tps = [tp_class.new(1), tp_class.new(2)]
    allow(person).to receive(:travel_plans).and_return(tps)

    class TPCellStub < Trailblazer::Cell
      def show
        "Travel plan #{model.id}"
      end
    end
    allow(described_class).to receive(:travel_plan_cell) { TPCellStub }

    rendered = cell(person, card_products: []).()

    expect(rendered).to have_no_content 'User has no upcoming travel plans'
    expect(rendered).to have_content 'Travel plan 1'
    expect(rendered).to have_content 'Travel plan 2'
  end

  example 'with home airports' do
    airport_class = Struct.new(:id)
    airports = [airport_class.new(1), airport_class.new(2)]
    allow(person).to receive(:home_airports).and_return(airports)

    class HAListItemCellStub < Trailblazer::Cell
      def show
        "<li>Airport #{model.id}</li>"
      end
    end
    # holy mess of dependencies, Batman
    allow(AdminArea::HomeAirports::Cell::List).to receive(:item_cell) { HAListItemCellStub }

    rendered = cell(person, card_products: []).()

    expect(rendered).to have_selector 'li', text: 'Airport 1'
    expect(rendered).to have_selector 'li', text: 'Airport 2'
  end

  example 'recommendation notes' do
    rn_0 = RecommendationNote.new(id: 8, account: account, content: 'Hola', created_at: Time.now)
    rn_1 = RecommendationNote.new(id: 9, account: account, content: 'Hello', created_at: Time.now)

    allow(person).to receive(:recommendation_notes).and_return([rn_0, rn_1])

    rendered = cell(person, card_products: []).()

    expect(rendered).to have_content 'Recommendation Notes'
    expect(rendered).to have_content 'Hola'
    expect(rendered).to have_content 'Hello'
  end

  let(:jan) { Date.parse("2015-01-01") }
  let(:mar) { Date.parse("2015-03-01") }
  let(:oct) { Date.parse("2015-10-01") }
  let(:dec) { Date.parse("2015-12-01") }

  let(:bank) { Bank.all.first }
  let(:card_product) { build(:card_product, bank: bank, currency: Currency.new) }

  example 'with card accounts' do
    open   = Card.new(id: 100, opened_on: jan, person: person, card_product: card_product)
    closed = Card.new(id: 101, opened_on: mar, closed_on: oct, person: person, card_product: card_product)
    allow(person).to receive(:card_accounts) { [open, closed] }

    rendered = cell(person, card_products: []).()

    expect(rendered).to have_selector '#admin_person_card_accounts #card_account_100'
    expect(rendered).to have_selector '#admin_person_card_accounts #card_account_101'

    expect(rendered).to have_no_content 'User has no existing card accounts'

    # says when they were opened/closed:
    expect(rendered).to have_selector '#card_account_100 .card_opened_on', text: 'Jan 2015'
    expect(rendered).to have_selector '#card_account_100 .card_closed_on', text: '-'
    expect(rendered).to have_selector '#card_account_101 .card_opened_on', text: 'Mar 2015'
    expect(rendered).to have_selector '#card_account_101 .card_closed_on', text: 'Oct 2015'
  end

  example 'person has received recommendations' do
    card_product = create(:card_product)
    offer = create_offer(card_product: card_product)

    person = create_account.owner

    rec = person.cards.create!(offer: offer, recommended_at: jan)
    clicked = person.cards.create!(offer: offer, seen_at: jan, recommended_at: mar, clicked_at: oct)
    declined = person.cards.create!(offer: offer, recommended_at: oct, seen_at: mar, declined_at: dec, decline_reason: 'because')

    rendered = cell(person, card_products: []).()

    def have(selector, text = nil)
      have_selector selector, text: text
    end

    wrapper = '#admin_person_card_recommendations'
    # debugger
    expect(rendered).to have "#{wrapper} #card_recommendation_#{rec.id}"
    expect(rendered).to have "#{wrapper} #card_recommendation_#{clicked.id}"
    expect(rendered).to have "#{wrapper} #card_recommendation_#{declined.id}"

    wrapper = "#card_recommendation_#{rec.id}"
    expect(rendered).to have "#{wrapper} .card_recommendation_status", 'Recommended'
    expect(rendered).to have "#{wrapper} .card_recommendation_recommended_at", '01/01/15'
    expect(rendered).to have "#{wrapper} .card_recommendation_seen_at", '-'
    expect(rendered).to have "#{wrapper} .card_recommendation_clicked_at", '-'
    expect(rendered).to have "#{wrapper} .card_recommendation_applied_on", '-'

    wrapper = "#card_recommendation_#{clicked.id}"
    expect(rendered).to have "#{wrapper} .card_recommendation_recommended_at", '03/01/15'
    expect(rendered).to have "#{wrapper} .card_recommendation_seen_at", '01/01/15'
    expect(rendered).to have "#{wrapper} .card_recommendation_clicked_at", '10/01/15'
    expect(rendered).to have "#{wrapper} .card_recommendation_applied_on", '-'
    expect(rendered).to have "#{wrapper} .card_recommendation_status", 'Recommended'

    wrapper = "#card_recommendation_#{declined.id}"
    expect(rendered).to have "#{wrapper} .card_recommendation_recommended_at", '10/01/15'
    expect(rendered).to have "#{wrapper} .card_recommendation_seen_at", '03/01/15'
    expect(rendered).to have "#{wrapper} .card_recommendation_clicked_at", '-'
    expect(rendered).to have "#{wrapper} .card_recommendation_declined_at", '12/01/15'
    expect(rendered).to have "#{wrapper} .card_recommendation_status", 'Declined'
    expect(rendered).to have_selector 'a[data-toggle="tooltip"][title=because]'
  end

  example 'products table' do
    def offer_selector(offer)
      "#admin_recommend_offer_#{offer.id}"
    end

    def product_selector(product)
      "#admin_recommend_card_product_#{product.id}"
    end

    currency = create_currency
    product = create(:card_product, currency: currency)
    product_with_no_currency = create(:card_product, currency: nil)

    o_0 = create_offer(card_product: product)
    o_1 = create_offer(card_product: product_with_no_currency)

    rendered = cell(person, card_products: CardProduct.all).()
    expect(rendered).to have_selector(product_selector(product))
    expect(rendered).to have_selector(product_selector(product_with_no_currency))
    expect(rendered).to have_selector(offer_selector(o_0))
    expect(rendered).to have_selector(offer_selector(o_1))
  end
end
