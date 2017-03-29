require 'rails_helper'

RSpec.describe Card do
  let(:card) { described_class.new(opened_on: Date.today - 1) }

  example '#status' do
    expect(card.status).to eq 'open'
    card.closed_on = Date.today
    expect(card.status).to eq 'closed'
  end

  example '#closed?' do
    expect(card.closed?).to be false
    card.closed_on = Date.today
    expect(card.closed?).to be true
  end
end
