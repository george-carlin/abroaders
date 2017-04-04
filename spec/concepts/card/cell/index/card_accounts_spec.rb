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
    let!(:companion) { account.people.companion.new(first_name: 'Gabi') }

    example 'with no cards' do
      rendered = show(account)
      expect(rendered).to have_content 'No cards!'
    end

    example 'only owner has cards' do
      acc = owner.card_accounts.new(id: 1, opened_on: today, product: product)
      allow(account).to receive(:card_accounts) { [acc] }
      rendered = show(account)
      expect(rendered).to have_selector '#card_1'
      expect(rendered).not_to have_content 'Erik has no cards'
      expect(rendered).to have_content 'Gabi has no cards'
    end

    example 'only companion has cards' do
      acc = companion.card_accounts.new(id: 2, opened_on: today, product: product)
      allow(account).to receive(:card_accounts) { [acc] }
      rendered = show(account)
      expect(rendered).to have_selector '#card_2'
      expect(rendered).to have_content 'Erik has no cards'
      expect(rendered).not_to have_content 'Gabi has no cards'
    end

    example 'both people have cards' do
      ca_0 = owner.card_accounts.new(id: 3, opened_on: today, product: product)
      ca_1 = companion.card_accounts.new(id: 4, opened_on: today, product: product)
      allow(account).to receive(:card_accounts) { [ca_0, ca_1] }
      rendered = show(account)
      expect(rendered).to have_selector '#card_3'
      expect(rendered).to have_selector '#card_4'
      expect(rendered).not_to have_content 'Erik has no cards'
      expect(rendered).not_to have_content 'Gabi has no cards'
    end
  end
end
