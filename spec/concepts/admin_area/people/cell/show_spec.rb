require 'cells_helper'

RSpec.describe AdminArea::People::Cell::Show do
  controller AdminArea::PeopleController

  let(:account) { Account.new(id: 1, created_at: Time.now) }
  let(:aw_email) { "totallyawesomedude@example.com" }

  let(:person) do
    Person.new(
      id: 5,
      account: account,
      award_wallet_email: aw_email,
      first_name: 'Erik',
    )
  end

  # result keys:
  #   account
  #   balances
  #   home_airports
  #   offers
  #   person
  #   recommendation_notes
  #   regions_of_interest
  #   travel_plans
  def get_result(data = {})
    Trailblazer::Operation::Result.new(
      true,
      'account'  => account,
      'balances' => data.fetch(:balances, []),
      'home_airports' => data.fetch(:home_airports, []),
      'offers' => data.fetch(:offers, []),
      'person' => person,
      'recommendation_notes' => data.fetch(:recommendation_notes, []),
      'regions_of_interest' => data.fetch(:regions_of_interest, []),
      'travel_plans' => data.fetch(:travel_plans, []),
    )
  end

  example 'basic information' do
    rendered = show(get_result)
    expect(rendered).to have_content account.created_at.strftime('%D')
    # person's name as the page header
    expect(rendered).to have_selector 'h1', text: 'Erik'
    # award wallet email
    expect(rendered).to have_content "AwardWallet email: #{aw_email}"
    expect(rendered).to have_content 'User has not added their spending info'
    expect(rendered).to have_content 'User has no upcoming travel plans'
    expect(rendered).to have_content 'User has no existing card accounts'
    # no recommendations, so no last recs timestamp:
    expect(rendered).not_to have_selector '.person_last_recommendations_at'
    # no recommendation notes yet:
    expect(rendered).to have_no_content 'Recommendation Notes'
  end

  example 'with spending info' do
    person.build_spending_info(
      credit_score: 678,
      has_business: :with_ein,
      business_spending_usd: 1500,
    )
    rendered = show(get_result)
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

    class TPCellStub < Trailblazer::Cell
      def show
        "Travel plan #{model.id}"
      end
    end
    allow(described_class).to receive(:travel_plan_cell) { TPCellStub }

    rendered = show(get_result(travel_plans: tps))

    expect(rendered).to have_no_content 'User has no upcoming travel plans'
    expect(rendered).to have_content 'Travel plan 1'
    expect(rendered).to have_content 'Travel plan 2'
  end

  example 'with home airports' do
    airport_class = Struct.new(:id)
    airports = [airport_class.new(1), airport_class.new(2)]

    class HAListItemCellStub < Trailblazer::Cell
      def show
        "<li>Airport #{model.id}</li>"
      end
    end
    # holy mess of dependencies, Batman
    allow(AdminArea::HomeAirports::Cell::List).to receive(:item_cell) { HAListItemCellStub }

    rendered = show(get_result(home_airports: airports))

    expect(rendered).to have_selector 'li', text: 'Airport 1'
    expect(rendered).to have_selector 'li', text: 'Airport 2'
  end

  example 'recommendation notes' do
    rn_0 = RecommendationNote.new(account: account, content: 'Hola', created_at: Time.now)
    rn_1 = RecommendationNote.new(account: account, content: 'Hello', created_at: Time.now)

    result = get_result(
      recommendation_notes: [rn_0, rn_1],
    )
    rendered = show(result)
    expect(rendered).to have_content 'Recommendation Notes'
    expect(rendered).to have_content 'Hola'
    expect(rendered).to have_content 'Hello'
    # TODO test it escapes XSS
  end

  let(:jan) { Date.parse("2015-01-01") }
  let(:mar) { Date.parse("2015-03-01") }
  let(:oct) { Date.parse("2015-10-01") }
  let(:dec) { Date.parse("2015-12-01") }

  let(:bank) { Bank.new(personal_code: 1, name: 'B') }
  let(:product) { build(:product, bank: bank, currency: Currency.new) }

  example 'with card accounts' do
    open   = Card.new(id: 100, opened_on: jan, person: person, product: product)
    closed = Card.new(id: 101, opened_on: mar, closed_on: oct, person: person, product: product)
    allow(person).to receive(:card_accounts) { [open, closed] }

    rendered = show(get_result)

    expect(rendered).to have_selector '#admin_person_cards #card_100'
    expect(rendered).to have_selector '#admin_person_cards #card_101'

    expect(rendered).to have_no_content 'User has no existing card accounts'

    within "#card_100" do
      expect(rendered).to have_selector '.card_opened_on', text: 'Jan 2015'
      expect(rendered).to have_selector '.card_closed_on', text: '-'
      expect(rendered).to have_selector '.card_status', text: 'Open'
    end

    within "#card_101" do
      expect(rendered).to have_selector '.card_status', text: 'Closed'
      # says when they were opened/closed:
      expect(rendered).to have_selector '.card_opened_on', text: 'Mar 2015'
      expect(rendered).to have_selector '.card_closed_on', text: 'Oct 2015'
    end
  end

  example 'person has received recommendations' do
    skip # TODO
    offer = Offer.new(product: product)
    allow(person).to receive(:card_recommendations) do
      [
        # new rec:
        Card.new(id: 50, offer: offer, recommended_at: jan, person: person, product: product),
        # clicked rec:
        Card.new(id: 51, offer: offer, seen_at: jan, recommended_at: mar, clicked_at: oct, product: product),
        # declined rec:
        Card.new(id: 52, offer: offer, recommended_at: oct, seen_at: mar, declined_at: dec, decline_reason: 'because', product: product),
      ]
    end

    last_recs_date = 5.days.ago
    person.last_recommendations_at = last_recs_date

    rendered = show(get_result)

    expect(rendered).to have_selector "#admin_person_cards_table"

    within '#admin_person_cards_table' do
      expect(rendered).to have_selector '#card_50'
      expect(rendered).to have_selector '#card_51'
      expect(rendered).to have_selector '#card_52'

      within '#card_50' do
        expect(rendered).to have_selector '.card_status', text: 'Recommended'
        expect(rendered).to have_selector '.card_recommended_at', text: '01/01/15'
        expect(rendered).to have_selector '.card_seen_at',        text: '-'
        expect(rendered).to have_selector '.card_clicked_at',     text: '-'
        expect(rendered).to have_selector '.card_applied_on',     text: '-'
      end

      within '#card_51' do
        expect(rendered).to have_selector '.card_recommended_at', text: '03/01/15'
        expect(rendered).to have_selector '.card_seen_at',        text: '01/01/15'
        expect(rendered).to have_selector '.card_clicked_at',     text: '10/01/15'
        expect(rendered).to have_selector '.card_applied_on',     text: '-'
        expect(rendered).to have_selector '.card_status', text: 'Recommended'
      end

      within '#card_52' do
        expect(rendered).to have_selector '.card_recommended_at', text: '10/01/15'
        expect(rendered).to have_selector '.card_seen_at',        text: '03/01/15'
        expect(rendered).to have_selector '.card_clicked_at',     text: '-'
        expect(rendered).to have_selector '.card_declined_at',    text: '12/01/15'
        expect(rendered).to have_selector '.card_status', text: 'Declined'
        expect(rendered).to have_selector 'a[data-toggle="tooltip"]'
        expect(find('a[data-toggle="tooltip"]')['title']).to eq 'because'
      end
    end

    # displays the last recs timestamp:
    last_recs = last_recs_date.strftime("%D")
    expect(rendered).to have_selector '.person_last_recommendations_at', text: last_recs
  end
end
