require 'rails_helper'

RSpec.describe 'admin/people#show card & offer filters', :js, :manual_clean do
  include_context 'logged in as admin'

  let(:account) { create(:account, :eligible, :onboarded) }
  let(:person) { account.owner }

  before(:all) do
    @chase   = create(:bank, name: "Chase")
    @us_bank = create(:bank, name: "US Bank")

    @currencies = create_list(:currency, 3, type: :airline)

    def create_product(bp, bank, currency)
      product = create(:card_product, bp, bank_id: bank.id, currency: currency)
      # make sure every product has at least one offer:
      create_offer(product: product)
      product
    end

    @products = [
      @chase_b = create_product(:business, @chase,   @currencies[0]),
      @chase_p = create_product(:personal, @chase,   @currencies[1]),
      @usb_b   = create_product(:business, @us_bank, @currencies[2]),
    ]
  end

  before { visit admin_person_path(person) }

  let(:all_banks) { :card_bank_filter_all }
  let(:chase_check_box)   { :"card_bank_filter_#{@chase.id}" }
  let(:us_bank_check_box) { :"card_bank_filter_#{@us_bank.id}" }

  def recommendable_card_product_selector(product)
    "#admin_recommend_card_product_#{product.id}"
  end

  def page_should_have_recommendable_products(*products)
    products.each do |product|
      expect(page).to have_selector recommendable_card_product_selector(product)
    end
  end

  def page_should_not_have_recommendable_products(*products)
    products.each do |product|
      expect(page).to have_no_selector recommendable_card_product_selector(product)
    end
  end

  example 'filtering by b/p' do
    uncheck :card_bp_filter_business
    page_should_have_recommendable_products(@chase_p)
    page_should_not_have_recommendable_products(@chase_b, @usb_b)
    uncheck :card_bp_filter_personal
    page_should_not_have_recommendable_products(*@products)
    check :card_bp_filter_business
    page_should_have_recommendable_products(@chase_b, @usb_b)
    page_should_not_have_recommendable_products(@chase_p)
    check :card_bp_filter_personal
    page_should_have_recommendable_products(*@products)
  end

  example 'filtering by bank' do
    Bank.all.each do |bank|
      expect(page).to have_field :"card_bank_filter_#{bank.id}"
    end

    uncheck chase_check_box
    page_should_have_recommendable_products(@usb_b)
    page_should_not_have_recommendable_products(@chase_b, @chase_p)
    uncheck us_bank_check_box
    page_should_not_have_recommendable_products(*@products)
    check chase_check_box
    page_should_have_recommendable_products(@chase_b, @chase_p)
    page_should_not_have_recommendable_products(@usb_b)
    check us_bank_check_box
    page_should_have_recommendable_products(*@products)
  end

  example 'toggling all banks' do
    uncheck all_banks
    page_should_not_have_recommendable_products(*@products)
    Bank.all.each do |bank|
      expect(find("#card_bank_filter_#{bank.id}")).not_to be_checked
    end
    check all_banks
    page_should_have_recommendable_products(*@products)
    Bank.all.each do |bank|
      expect(find("#card_bank_filter_#{bank.id}")).to be_checked
    end

    # it gets checked/unchecked automatically as I click other CBs:
    uncheck chase_check_box
    expect(find("##{all_banks}")).not_to be_checked
    check chase_check_box
    expect(find("##{all_banks}")).to be_checked
  end
end
