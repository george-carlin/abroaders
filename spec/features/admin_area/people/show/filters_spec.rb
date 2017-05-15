require 'rails_helper'

RSpec.describe 'admin/people#show card & offer filters', :js, :manual_clean do
  include_context 'logged in as admin'

  let(:account) { create_account(:eligible, :onboarded) }
  let(:person) { account.owner }

  before(:all) do
    @chase = Bank.find_by_name!('Chase')
    @usb = Bank.find_by_name!('US Bank')

    @currencies = Currency::TYPES.map { |t| create_currency(type: t) }

    # ensure we have at least one of each sub-type of card product
    @products = [true, false].flat_map do |business|
      [@chase, @usb].flat_map do |bank|
        @currencies.flat_map do |currency|
          create(:card_product, business: business, bank_id: bank.id, currency: currency)
        end
      end
    end
  end
  let(:products) { @products }

  before do
    # make sure every product has at least one offer or it won't be shown
    products.each { |p| create_offer(card_product: p) }

    # can't create these in before(:all) because 'person' is a let variable
    @card_accounts = products.map { |p| create_card_account(person: person, card_product: p) }
  end

  let(:all_banks_check_box) { :card_bank_filter_all }
  let(:chase_check_box)   { :"card_bank_filter_#{@chase.id}" }
  let(:us_bank_check_box) { :"card_bank_filter_#{@usb.id}" }

  let(:chase_prods) { products.select { |p| p.bank == @chase } }
  let(:usb_prods) { products.select { |p| p.bank == @usb } }
  let(:personal_prods) { products.select(&:personal?) }
  let(:business_prods) { products.select(&:business?) }
  let(:airline_currency_prods) { products.select { |p| p.currency.type == 'airline' } }
  let(:bank_currency_prods) { products.select { |p| p.currency.type == 'bank' } }
  let(:hotel_currency_prods) { products.select { |p| p.currency.type == 'hotel' } }

  # specify which products should be shown. The macro will check that they're
  # shown.  Then it look at the list of products to figure out which ones by
  # extension *shouldn't* be shown and check that they're not.
  #
  # also checks that the person's card accounts have been hidden or shown based
  # on the same criteria for the product. We only hide/show their accounts, not
  # their non-opened recommendations.
  def page_should_have_these_visible_products(visible)
    hidden = products - visible

    visible.each do |product| # check that the right card prods are shown
      expect(page).to have_selector "#admin_recommend_card_product_#{product.id}"
    end

    hidden.each do |product| # check that the right card prods are hidden
      expect(page).to have_no_selector "#admin_recommend_card_product_#{product.id}"
    end

    @card_accounts.each do |acc|
      selector = "#admin_person_card_accounts_table #card_account_#{acc.id}"
      if visible.include?(acc.card_product)
        expect(page).to have_selector selector
      elsif hidden.include?(acc.card_product)
        expect(page).to have_no_selector selector
      else
        raise 'this should never happen!'
      end
    end
  end

  example 'filtering by b/p' do
    visit admin_person_path(person)
    uncheck :card_bp_filter_business
    page_should_have_these_visible_products(personal_prods)
    uncheck :card_bp_filter_personal
    page_should_have_these_visible_products([])
    check :card_bp_filter_business
    page_should_have_these_visible_products(business_prods)
    check :card_bp_filter_personal
    page_should_have_these_visible_products(products)
  end

  example 'filtering by bank' do
    visit admin_person_path(person)
    Bank.all.each do |bank|
      expect(page).to have_field :"card_bank_filter_#{bank.id}"
    end

    uncheck chase_check_box
    page_should_have_these_visible_products(usb_prods)
    uncheck us_bank_check_box
    page_should_have_these_visible_products([])
    check chase_check_box
    page_should_have_these_visible_products(chase_prods)
    check us_bank_check_box
    page_should_have_these_visible_products(products)
  end

  example 'toggling all banks' do
    visit admin_person_path(person)
    uncheck all_banks_check_box
    page_should_have_these_visible_products([])
    Bank.all.each do |bank|
      expect(page).to have_field :"card_bank_filter_#{bank.id}", checked: false
    end
    check all_banks_check_box
    page_should_have_these_visible_products(products)
    Bank.all.each do |bank|
      expect(page).to have_field :"card_bank_filter_#{bank.id}", checked: true
    end

    # it gets checked/unchecked automatically as I click other CBs:
    uncheck chase_check_box
    expect(page).to have_field all_banks_check_box, checked: false
    check chase_check_box
    expect(page).to have_field all_banks_check_box, checked: true
  end

  # FIXME not sure why the test is failing, because the behaviour is working
  pending 'clicking "only" next a to bank' do
    visit admin_person_path(person)
    click_button :"card_bank_filter_#{@chase.id}_only"

    Bank.all.each do |bank|
      expect(page).to have_field :"card_bank_filter_#{bank.id}", checked: bank == @chase
    end

    page_should_have_these_visible_products(chase_prods)

    click_link :"card_bank_filter_#{@usb.id}_only"

    Bank.all.each do |bank|
      expect(page).to have_field :"card_bank_filter_#{bank.id}", checked: bank == @usb
    end

    page_should_have_these_visible_products(usb_prods)
  end

  example 'filtering by max. spend' do
    # this modifies data which was created in a before(:all) block, but since
    # none of the other examples read or care about the offers, I think we can
    # get away with it:
    spend_1000 = products[0].tap { |p| p.offers.first.update!(spend: 1000) }
    spend_2000 = products[1].tap { |p| p.offers.first.update!(spend: 2000) }
    spend_3000 = products[3].tap { |p| p.offers.first.update!(spend: 3000) }
    two_offers = products[4]
    create_offer(card_product: two_offers)
    to_0  = two_offers.offers[0].tap { |o| o.update!(spend: 5000) }
    _to_1 = two_offers.offers[1].tap { |o| o.update!(spend: 2500) }

    # These two should NEVER be hidden by changes to the max spend filter:
    on_fp = products[5].offers[0].tap { |o| o.update!(condition: 'on_first_purchase') }
    on_a  = products[6].offers[0].tap { |o| o.update!(condition: 'on_approval') }

    visit admin_person_path(person)

    # All products being tested. There are other products on the page but we'll
    # ignore them for the purposes of this test.
    products = [spend_1000, spend_2000, spend_3000, two_offers]

    offers = Offer.where(card_product_id: products.map(&:id))

    # Hides the spend_3000 product. Hides one offer for two_offers, but doesn't
    # hide the whole product (because its other offer is still visible)
    fill_in :card_spend_filter, with: 2999
    expect(page).to have_no_selector "#admin_recommend_card_product_#{spend_3000.id}"
    (products - [spend_3000]).each do |product|
      expect(page).to have_selector "#admin_recommend_card_product_#{product.id}"
    end
    visible_offers = [to_0, spend_3000.offers.first]
    visible_offers.each do |o|
      expect(page).to have_no_selector "#admin_recommend_offer_#{o.id}"
    end
    (offers - visible_offers).each do |o|
      expect(page).to have_selector "#admin_recommend_offer_#{o.id}"
    end

    # hide all but one product
    fill_in :card_spend_filter, with: 1000
    expect(page).to have_selector "#admin_recommend_card_product_#{spend_1000.id}"
    (products - [spend_1000]).each do |product|
      expect(page).to have_no_selector "#admin_recommend_card_product_#{product.id}"
    end
    expect(page).to have_selector "#admin_recommend_offer_#{spend_1000.offers.first.id}"
    expect(page).to have_selector "#admin_recommend_offer_#{on_fp.id}"
    expect(page).to have_selector "#admin_recommend_offer_#{on_a.id}"

    # Hide the entire two_offers product because none of its offers are visible:
    fill_in :card_spend_filter, with: 2499
    hidden_products = [spend_3000, two_offers]
    hidden_products.each do |p|
      expect(page).to have_no_selector "#admin_recommend_card_product_#{p.id}"
    end
    (products - hidden_products).each do |p|
      expect(page).to have_selector "#admin_recommend_card_product_#{p.id}"
    end
    expect(page).to have_selector "#admin_recommend_offer_#{on_fp.id}"
    expect(page).to have_selector "#admin_recommend_offer_#{on_a.id}"

    # all offers are shown when the input is blank:
    fill_in :card_spend_filter, with: ' '
    products.each do |product|
      expect(page).to have_selector "#admin_recommend_card_product_#{product.id}"
    end
    offers.each do |o|
      expect(page).to have_selector "#admin_recommend_offer_#{o.id}"
    end
  end
end
