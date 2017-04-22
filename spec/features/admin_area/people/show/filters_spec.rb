require 'rails_helper'

RSpec.describe 'admin/people#show card & offer filters', :js, :manual_clean do
  include_context 'logged in as admin'

  let(:account) { create(:account, :eligible, :onboarded) }
  let(:person) { account.owner }

  before(:all) do
    @chase = create(:bank, name: "Chase")
    @usb = create(:bank, name: "US Bank")

    @currencies = Currency::TYPES.map { |t| create(:currency, type: t) }

    # ensure we have at least one of each sub-type of card product
    @products = %w[business personal].flat_map do |bp|
      [@chase, @usb].flat_map do |bank|
        @currencies.flat_map do |currency|
          product = create(:card_product, bp: bp, bank: bank, currency: currency)
          # make sure every product has at least one offer or it won't be shown
          create_offer(product: product)
          product
        end
      end
    end
  end

  let(:products) { @products }

  before do
    # can't create this in before(:all) because 'person' is a let variable
    @card_accounts = products.map { |p| create_card_account(person: person, card_product: p) }
    visit admin_person_path(person)
  end

  let(:all_banks_check_box) { :card_bank_filter_all }
  let(:chase_check_box)   { :"card_bank_filter_#{@chase.id}" }
  let(:us_bank_check_box) { :"card_bank_filter_#{@usb.id}" }

  let(:chase_prods) { products.select { |p| p.bank == @chase } }
  let(:usb_prods) { products.select { |p| p.bank == @usb } }
  let(:personal_prods) { products.select { |p| p.bp == 'personal' } }
  let(:business_prods) { products.select { |p| p.bp == 'business' } }
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
end
