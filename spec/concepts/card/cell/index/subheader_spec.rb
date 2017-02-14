require 'cells_helper'

RSpec.describe Card::Cell::Index::Subheader do
  before do
    @a = Account.new
    @p = @a.people.new(owner: true, first_name: 'George')
  end

  example 'for a solo account' do
    rendered = show(nil, person: @p, account: @a)
    expect(rendered).not_to have_selector 'h3'
  end

  example 'for a couples account' do
    allow(@a).to receive(:couples?).and_return(true)
    rendered = show(nil, person: @p, account: @a)
    expect(rendered.to_s).to include "<h3>George's Cards</h3>"
  end

  it 'escapes HTML' do
    allow(@a).to receive(:couples?).and_return(true)
    companion = @a.people.new(owner: false, first_name: '<script>')
    rendered = show(nil, person: companion, account: @a)
    expect(rendered.to_s).to include "<h3>&lt;script&gt;'s Cards</h3>"
  end
end
