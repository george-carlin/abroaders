require 'cells_helper'

RSpec.describe Card::Cell::Index::CardAccounts do
  controller CardsController

  let(:bank)     { Bank.new(id: 999, name: 'My bank') }
  let(:product)  { CardProduct.new(id: 555, bank: bank, network: :visa) }
  let!(:account) { Account.new }
  let!(:owner)   { account.people.owner.new(first_name: 'Erik') }

  class ProductNameCellStub < Trailblazer::Cell
    def show
      "Card Product #{model.id}"
    end
  end

  let(:today) { Date.today }

  before do
    allow(CardAccount::Cell::Row).to \
      receive(:product_name_cell).and_return(ProductNameCellStub)
  end

  example 'solo account with no cards' do
    rendered = show(account)
    expect(rendered).to have_content 'No cards!'
  end

  example 'solo account with cards' do
    acc = owner.card_accounts.new(id: 10, product: product, opened_on: today)
    allow(account).to receive(:card_accounts) { [acc] }
    rendered = show(account)
    expect(rendered).to have_content ProductNameCellStub.(product).()
  end

  describe 'couples account' do
    # need to use saved records or the cell won't load the people correctly :/
    let(:product) { create(:card_product) }
    let(:account) { create(:account, :couples, :eligible, :onboarded) }
    let(:owner) { account.owner }
    let(:companion) { account.companion }

    example 'with no cards' do
      rendered = show(account)
      expect(rendered).to have_content 'No cards!'
    end

    example 'only owner has cards' do
      create_card_account(person: owner, opened_on: today, product: product)
      rendered = show(account)
      expect(rendered).to have_selector '#card_1'
      expect(rendered).not_to have_content "#{owner.first_name} has no cards"
      expect(rendered).to have_content "#{companion.first_name} has no cards"
    end

    example 'only companion has cards' do
      create_card_account(person: companion, opened_on: today, product: product)
      rendered = show(account)
      expect(rendered).to have_selector '#card_2'
      expect(rendered).to have_content "#{owner.first_name} has no cards"
      expect(rendered).not_to have_content "#{companion.first_name} has no cards"
    end

    example 'both people have cards' do
      create_card_account(person: owner, opened_on: today, product: product)
      create_card_account(person: companion, opened_on: today, product: product)
      rendered = show(account)
      expect(rendered).to have_selector '#card_3'
      expect(rendered).to have_selector '#card_4'
      expect(rendered).not_to have_content "#{owner.first_name} has no cards"
      expect(rendered).not_to have_content "#{companion.first_name} has no cards"
    end
  end
end
