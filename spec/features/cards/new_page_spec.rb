require 'rails_helper'

RSpec.describe 'new card page', :js do
  include_context 'logged in'

  let(:person) { account.owner }

  before do
    @banks = create_list(:bank, 2)
    @bank_0_products = [
      create(:card_product, :business, bank: @banks[0]),
      create(:card_product, :personal, bank: @banks[0]),
    ]
    @bank_1_products = [
      create(:card_product, :business, bank: @banks[1]),
      create(:card_product, :personal, bank: @banks[1], shown_on_survey: false),
    ]
    @products = @bank_0_products + @bank_1_products
    visit new_card_path
  end

  # <select> tags generated by Rails's date_select
  CLOSED_MONTH = :card_closed_at_2i
  CLOSED_YEAR  = :card_closed_at_1i
  OPENED_MONTH = :card_opened_at_2i
  OPENED_YEAR  = :card_opened_at_1i

  def full_name_for(product)
    CardProduct::Cell::FullName.(product, network_in_brackets: true).()
  end

  example 'selecting a bank' do
    # no products visible initially:
    @products.each do |product|
      expect(page).to have_no_content full_name_for(product)
    end
    # selecting a bank:
    select @banks[0].name, from: Card::Cell::New::SelectProduct::BankSelect::HTML_ID
    @bank_0_products.each do |product|
      expect(page).to have_content full_name_for(product)
    end
    @bank_1_products.each do |product|
      expect(page).to have_no_content full_name_for(product)
    end
    select @banks[1].name, from: Card::Cell::New::SelectProduct::BankSelect::HTML_ID
    @bank_0_products.each do |product|
      expect(page).to have_no_content full_name_for(product)
    end
    @bank_1_products.each do |product|
      expect(page).to have_content full_name_for(product)
    end
    # (shows all products, even those not shown on the survey)
  end

  describe 'selecting a product' do
    let(:product) { @bank_0_products.first }
    let(:year) { (Date.today.year - 1).to_s }

    before do
      select @banks[0].name, from: Card::Cell::New::SelectProduct::BankSelect::HTML_ID
      within "#card_product_#{product.id}" do
        click_link 'Add this Card'
      end
    end

    example 'form' do
      # shows form
      expect(page).to have_field OPENED_MONTH
      expect(page).to have_field OPENED_YEAR
      expect(page).to have_field :card_closed
      # showing/hiding the 'closed at' date select
      expect(page).to have_no_field CLOSED_MONTH
      expect(page).to have_no_field CLOSED_YEAR
      check :card_closed
      expect(page).to have_field CLOSED_MONTH
      expect(page).to have_field CLOSED_YEAR
      uncheck :card_closed
      expect(page).to have_no_field CLOSED_MONTH
      expect(page).to have_no_field CLOSED_YEAR
    end

    example 'adding an open card' do
      select 'Dec', from: OPENED_MONTH
      select year, from: OPENED_YEAR
      expect do
        click_button 'Save'
      end.to change { person.cards.count }.by(1)

      card = person.cards.last
      expect(card.opened_at).to eq Date.new(year.to_i, 12, 1)
      expect(card.closed_at).to be nil
      expect(page).to have_content full_name_for(person.cards.last.product)
    end

    example 'adding a closed card' do
      select 'Jan', from: OPENED_MONTH
      select year, from: OPENED_YEAR
      check :card_closed
      select 'Dec', from: CLOSED_MONTH
      select year, from: CLOSED_YEAR
      expect do
        click_button 'Save'
      end.to change { person.cards.count }.by(1)
      expect(page).to have_content full_name_for(person.cards.last.product)
    end

    example 'trying to save an invalid card' do
      # closed before opened:
      select 'Dec', from: OPENED_MONTH
      select year, from: OPENED_YEAR
      check :card_closed
      select 'Jan', from: CLOSED_MONTH
      select year, from: CLOSED_YEAR
      expect { click_button 'Save' }.not_to change { person.cards.count }
      expect(page).to have_error_message
      expect(find("##{CLOSED_MONTH}")[:disabled]).not_to be_truthy
      expect(find("##{CLOSED_YEAR}")[:disabled]).not_to be_truthy
    end

    context 'for a solo account' do
      it "doesn't ask which person to add the card to" do
        expect(page).not_to have_field :card_person_id
      end
    end
  end

  context 'for a couples account' do
    let!(:person) { create(:companion, account: account) }
    let(:product) { @bank_1_products.first }

    before do
      select @banks[1].name, from: Card::Cell::New::SelectProduct::BankSelect::HTML_ID
      within "#card_product_#{product.id}" do
        click_link 'Add this Card'
      end
    end

    example 'adding a card to companion' do
      select 'Dec', from: OPENED_MONTH
      select (Date.today.year - 5).to_s, from: OPENED_YEAR
      select person.first_name, from: :card_person_id
      expect do
        click_button 'Save'
      end.to change { person.cards.count }.by(1)
      expect(page).to have_content full_name_for(person.cards.last.product)
    end
  end
end