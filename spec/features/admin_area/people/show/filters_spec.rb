require 'rails_helper'

RSpec.describe 'admin/people#show card & offer filters', :js, :manual_clean do
  include_context 'logged in as admin'

  let(:account) { create(:account, :eligible, :onboarded) }
  let(:person) { account.owner }

  before(:all) do
    @chase = create(:bank, name: "Chase")
    @usb = create(:bank, name: "US Bank")

    @currencies = create_list(:currency, 3, type: :airline)

    @hotel_currency = create(:currency, type: 'hotel')
    @bank_currency = create(:currency, type: 'bank')

    def create_prod(bp, bank, currency)
      product = create(:card_product, bp, bank_id: bank.id, currency: currency)
      # make sure every product has at least one offer or it won't be shown
      create_offer(product: product)
      product
    end

    @products = [
      # ivar name format: @BankName_BP_CurrencyType
      @chase_b_a = create_prod(:business, @chase, @currencies[0]),
      @chase_p_a = create_prod(:personal, @chase, @currencies[1]),
      @usb_b_a   = create_prod(:business, @usb, @currencies[2]),
      @usb_p_h = create_prod(:personal, @usb, @hotel_currency),
      @chase_b_b = create_prod(:business, @chase, @bank_currency),
    ]
  end

  before { visit admin_person_path(person) }

  let(:all_banks_check_box) { :card_bank_filter_all }
  let(:chase_check_box)   { :"card_bank_filter_#{@chase.id}" }
  let(:us_bank_check_box) { :"card_bank_filter_#{@usb.id}" }

  let(:chase_prods) { [@chase_b_a, @chase_b_b, @chase_p_a] }
  let(:usb_prods) { [@usb_p_h, @usb_b_a] }
  let(:personal_prods) { [@chase_p_a, @usb_p_h] }
  let(:business_prods) { [@chase_b_a, @chase_b_b, @usb_b_a] }
  let(:airline_currency_prods) { [@chase_b_a, @chase_b_b, @chase_p_a] }
  let(:bank_currency_prods) { [@chase_b_b] }
  let(:hotel_currency_prods) { [@usb_p_h] }
  let(:products) { @products }

  def page_should_have_these_visible_products(visible)
    visible.each do |product|
      expect(page).to have_selector "#admin_recommend_card_product_#{product.id}"
    end
    (products - visible).each do |product|
      expect(page).to have_no_selector "#admin_recommend_card_product_#{product.id}"
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
end
