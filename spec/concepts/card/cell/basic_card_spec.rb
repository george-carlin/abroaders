require 'rails_helper'

RSpec.describe Card::Cell::BasicCard, type: :view do
  let(:cell) { described_class }

  def render_cell(*args)
    instance = cell.(*args)
    # this would be much better handled by some kind of dependency-injection
    # system :/
    allow(instance).to receive(:edit_card_path).and_return '/stubbed/path'
    allow(instance).to receive(:card_path).and_return '/stubbed/path'
    allow(instance).to receive(:product_full_name).and_return 'My awesome card'
    allow(instance).to receive(:bank_name).and_return 'My awesome bank'
    allow(instance).to receive(:image).and_return '<img src="stub" />'
    instance.()
  end

  let(:card) { Card.new(opened_at: Date.new(2015, 6, 1)) }

  it 'displays info about the card' do
    rendered = render_cell(card)
    expect(rendered).to have_content "Card Name: My awesome card"
    expect(rendered).to have_content 'Bank: My awesome bank'
    expect(rendered).to have_content 'Bank: My awesome bank'
    expect(rendered).not_to have_content 'Closed:'
  end

  example 'card is closed' do
    card.closed_at = Date.new(2016, 2, 1)
    rendered = render_cell(card)
    expect(rendered).to have_content 'Closed: Feb 2016'
  end

  example ':editable option' do
    # with:
    expect(render_cell(card)).not_to have_link 'Edit'
    # without:
    expect(render_cell(card, editable: true)).to have_link 'Edit'
  end
end
