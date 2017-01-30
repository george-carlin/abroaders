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

  def full_name_for(product)
    CardProduct::Cell::FullName.(product).()
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
    before do
      select @banks[0].name, from: Card::Cell::New::SelectProduct::BankSelect::HTML_ID
      within "#card_product_#{product.id}" do
        click_link 'Add this Card'
      end
    end

    example 'form' do
      # shows form
      expect(page).to have_field :card_opened_at_1i
      expect(page).to have_field :card_opened_at_2i
      expect(page).to have_field :card_closed
      # showing/hiding the 'closed at' date select
      expect(page).to have_field :card_closed_at_1i
      expect(page).to have_field :card_closed_at_2i
      check :card_closed
      expect(page).to have_field :card_closed_at_1i
      expect(page).to have_field :card_closed_at_2i
      uncheck :card_closed
      expect(page).to have_field :card_closed_at_1i
      expect(page).to have_field :card_closed_at_2i
    end

    let(:year) { (Date.today.year - 1).to_s }

    example 'adding an open card' do
      select 'Dec', from: :card_opened_at_1i
      select year, from: :card_opened_at_2i
      expect do
        click_button 'Save'
      end.to change { person.cards.count }.by(1)
      expect(page).to have_content full_name_for(person.cards.last.product)
    end

    example 'adding a closed card' do
      select 'Jan', from: :card_opened_at_1i
      select year, from: :card_opened_at_2i
      check :card_closed
      select 'Dec', from: :card_closed_at_1i
      select year, from: :card_closed_at_2i
      expect do
        click_button 'Save'
      end.to change { person.cards.count }.by(1)
      expect(page).to have_content full_name_for(person.cards.last.product)
    end

    example 'trying to save an invalid card' do
      # closed before opened:
      select 'Dec', from: :card_opened_at_1i
      select year, from: :card_opened_at_2i
      check :card_closed
      select 'Jan', from: :card_closed_at_1i
      select year, from: :card_closed_at_2i
      expect do
        click_button 'Save'
      end.to change { person.cards.count }.by(1)
      expect(page).to have_content full_name_for(person.cards.last.product)
    end

    context 'for a solo account' do
      it "doesn't ask which person to add the card to" do
        expect(page).not_to have_field :card_person_id
      end
    end
  end

  context 'for a couples account' do
    let!(:person) { create(:companion, account: account) }

    before do
      select @banks[0].name, from: Card::Cell::New::SelectProduct::BankSelect::HTML_ID
      click_link 'Add this card'
    end

    example 'adding a card to companion' do
      select 'Dec', from: :card_opened_at_1i
      select year, from: :card_opened_at_2i
      select person.first_name, from: :card_person_id
      expect do
        click_button 'Save'
      end.to change { person.cards.count }.by(1)
      expect(page).to have_content full_name_for(person.cards.last.product)
    end
  end
end
