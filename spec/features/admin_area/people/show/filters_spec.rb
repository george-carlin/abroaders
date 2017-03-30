require 'rails_helper'

RSpec.describe 'admin/people#show card/offer filters', :js, :manual_clean do
  include_context 'logged in as admin'

  let(:account) { create(:account, :onboarded, :eligible) }
  let(:person) { account.owner }

  before(:all) do
    @chase   = create(:bank, name: "Chase")
    @us_bank = create(:bank, name: "US Bank")

    @currencies = [
      create(:currency, alliance_name: 'OneWorld'),
      create(:currency, alliance_name: 'SkyTeam'),
      create(:currency, alliance_name: 'OneWorld'),
    ]

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

    @one_world_cards = [@chase_b, @usb_b]
  end


  before { visit admin_person_path(person) }

  let(:business_check_box) { :card_bp_filter_business }
  let(:personal_check_box) { :card_bp_filter_personal }
  let(:all_banks) { :card_bank_filter_all }
  let(:all_ow) { :card_currency_alliance_filter_all_for_one_world }
  let(:all_st) { :card_currency_alliance_filter_all_for_sky_team }
  let(:chase_check_box)   { :"card_bank_filter_#{@chase.id}" }
  let(:us_bank_check_box) { :"card_bank_filter_#{@us_bank.id}" }

  def recommendable_card_product_selector(product)
    '#' << dom_id(product, :admin_recommend)
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
    uncheck business_check_box
    page_should_have_recommendable_products(@chase_p)
    page_should_not_have_recommendable_products(@chase_b, @usb_b)
    uncheck personal_check_box
    page_should_not_have_recommendable_products(*@products)
    check business_check_box
    page_should_have_recommendable_products(@chase_b, @usb_b)
    page_should_not_have_recommendable_products(@chase_p)
    check personal_check_box
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

  example 'filtering by currency' do
    Currency.pluck(:id).each do |currency_id|
      expect(page).to have_field :"card_currency_filter_#{currency_id}"
    end

    uncheck "card_currency_filter_#{@chase_b.currency.id}"
    uncheck "card_currency_filter_#{@chase_p.currency.id}"
    page_should_not_have_recommendable_products(@chase_b, @chase_p)
    uncheck "card_currency_filter_#{@usb_b.currency.id}"
    page_should_not_have_recommendable_products(*@products)
    check "card_currency_filter_#{@chase_p.currency.id}"
    page_should_have_recommendable_products(@chase_p)
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

  example 'toggling all currencies' do
    uncheck all_ow
    uncheck all_st

    page_should_not_have_recommendable_products(*@products)
    Currency.all.each do |currency|
      expect(find("#card_currency_filter_#{currency.id}")).not_to be_checked
    end

    check all_ow
    check all_st

    page_should_have_recommendable_products(*@products)
    Currency.all.each do |currency|
      expect(find("#card_currency_filter_#{currency.id}")).to be_checked
    end
  end

  example 'toggling all currencies in an alliance' do
    uncheck all_ow
    page_should_not_have_recommendable_products(*@one_world_cards)
    Currency.where(alliance_name: 'OneWorld').each do |currency|
      expect(find("#card_currency_filter_#{currency.id}")).not_to be_checked
    end
    check all_ow
    page_should_have_recommendable_products(*@one_world_cards)
    Currency.where(alliance_name: 'OneWorld').each do |currency|
      expect(find("#card_currency_filter_#{currency.id}")).to be_checked
    end

    # it gets checked/unchecked automatically as I click other CBs:
    uncheck "card_currency_filter_#{@one_world_cards[0].id}"
    expect(find("##{all_ow}")).not_to be_checked
    check "card_currency_filter_#{@one_world_cards[0].id}"
    expect(find("##{all_ow}")).to be_checked
  end
end
