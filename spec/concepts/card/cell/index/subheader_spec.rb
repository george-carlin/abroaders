require 'rails_helper'

RSpec.describe Card::Cell::Index::Subheader, type: :view do
  let(:cell) { described_class }

  before do
    @a = Account.new
    @p = @a.people.new(owner: true, first_name: 'George')
  end

  example 'for a solo account' do
    rendered = cell.(nil, person: @p, account: @a).()
    expect(rendered).to eq ''
  end

  example 'for a couples account' do
    allow(@a).to receive(:couples?).and_return(true)
    rendered = cell.(nil, person: @p, account: @a).()
    expect(rendered).to eq "<h3>George's Cards</h3>"
  end

  it 'escapes HTML' do
    allow(@a).to receive(:couples?).and_return(true)
    companion = @a.people.new(owner: false, first_name: '<script>')
    rendered = cell.(nil, person: companion, account: @a).()
    expect(rendered).to eq "<h3>&lt;script&gt;'s Cards</h3>"
  end
end
