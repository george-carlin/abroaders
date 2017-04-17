require 'cells_helper'

RSpec.describe CardAccount::Cell::Row do
  controller CardsController

  def show(model, opts = {})
    instance = cell(described_class, model, opts)
    # this would be much better handled by some kind of dependency-injection
    # system :/
    allow(instance).to receive(:edit_card_account_path).and_return '/stubbed/path'
    allow(instance).to receive(:card_account_path).and_return '/stubbed/path'
    allow(instance).to receive(:product_full_name).and_return 'My awesome card'
    allow(instance).to receive(:bank_name).and_return 'My awesome bank'
    allow(instance).to receive(:image).and_return '<img src="stub" />'
    instance.()
  end

  let(:card_account) { CardAccount.new(opened_on: Date.new(2015, 6, 1)) }

  it 'displays info about the card_account' do
    rendered = show(card_account)
    expect(rendered).to have_content "Card Name: My awesome card"
    expect(rendered).to have_content 'Bank: My awesome bank'
    expect(rendered).to have_content 'Bank: My awesome bank'
    expect(rendered).not_to have_content 'Closed:'
  end

  example 'card account is closed' do
    card_account.closed_on = Date.new(2016, 2, 1)
    expect(show(card_account)).to have_content 'Closed: Feb 2016'
  end

  example ':editable option' do
    # with:
    rendered = show(card_account)
    expect(rendered).not_to have_link 'Edit'
    expect(rendered).not_to have_link 'Delete'
    # without:
    rendered = show(card_account, editable: true)
    expect(rendered).to have_link 'Edit'
    expect(rendered).to have_link 'Delete'
  end
end
