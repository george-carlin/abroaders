require 'cells_helper'

RSpec.describe Card::Cell::Index::CardAccounts do
  controller CardsController

  let(:bank) { Bank.all.first }
  let(:card_product) { create(:card_product, bank: bank) }
  let!(:account) { Account.new }
  let!(:owner) { account.people.owner.new(first_name: 'Erik') }

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

  example 'solo account with no card accounts' do
    rendered = cell(account).()
    expect(rendered).to have_content 'No cards!'
  end

  example 'solo account with card accounts' do
    offer = card_product.unknown_offer
    acc = owner.card_accounts.new(id: 10, offer: offer, opened_on: today)
    allow(account).to receive(:card_accounts) { [acc] }
    rendered = cell(account).()
    expect(rendered).to have_content ProductNameCellStub.(card_product).()
  end

  describe 'couples account' do
    # need to use saved records or the cell won't load the people correctly :/
    let(:card_product) { create(:card_product) }
    let(:account) { create_account(:couples, :eligible, :onboarded) }
    let(:owner) { account.owner }
    let(:companion) { account.companion }

    example 'with no card accounts' do
      rendered = cell(account).()
      expect(rendered).to have_content 'No cards!'
    end

    example 'only owner has card accounts' do
      create_card_account(person: owner, opened_on: today, card_product: card_product)
      rendered = cell(account).()
      expect(rendered).to have_selector '#card_account_1'
      expect(rendered).not_to have_content "#{owner.first_name} has no cards"
      expect(rendered).to have_content "#{companion.first_name} has no cards"
    end

    example 'only companion has card accounts' do
      create_card_account(person: companion, opened_on: today, card_product: card_product)
      rendered = cell(account).()
      expect(rendered).to have_selector '#card_account_2'
      expect(rendered).to have_content "#{owner.first_name} has no cards"
      expect(rendered).not_to have_content "#{companion.first_name} has no cards"
    end

    example 'both people have card accounts' do
      create_card_account(person: owner, opened_on: today, card_product: card_product)
      create_card_account(person: companion, opened_on: today, card_product: card_product)
      rendered = cell(account).()
      expect(rendered).to have_selector '#card_account_3'
      expect(rendered).to have_selector '#card_account_4'
      expect(rendered).not_to have_content "#{owner.first_name} has no cards"
      expect(rendered).not_to have_content "#{companion.first_name} has no cards"
    end
  end
end
