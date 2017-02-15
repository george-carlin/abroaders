require 'cells_helper'

RSpec.describe Balance::Cell::BalanceTable do
  controller BalancesController

  class BalanceCellStub < Trailblazer::Cell
    def show
      "Balance #{model.id}"
    end
  end

  def show(model, opts = {})
    super(model, opts.merge(balance_cell: BalanceCellStub))
  end

  let(:balance_class) { Struct.new(:id) }
  let(:person) { Person.new(id: 1, first_name: 'Erik') }

  example '' do
    balances = [balance_class.new(123), balance_class.new(321)]
    rendered = show(person, balances: balances)
    # text for link text EXACT match
    expect(rendered).to have_xpath("//a[text()='Add new']")
    expect(rendered).to have_content 'Balance 123'
    expect(rendered).to have_content 'Balance 321'
    expect(rendered).to have_selector 'h1', text: 'My points'
  end

  example 'with no balances' do
    rendered = show(person, balances: [])
    expect(rendered).to have_content 'No balances'
  end

  example 'with use_name: true' do
    rendered = show(person, balances: [], use_name: true)

    expect(rendered).to have_link 'Add new balance for Erik'
    expect(rendered).to have_selector 'h1', text: "Erik's points"
  end

  example 'with use_name: false' do
    rendered = show(person, balances: [], use_name: false)
    # text for link text EXACT match:
    expect(rendered).to have_xpath("//a[text()='Add new']")
    expect(rendered).to have_selector 'h1', text: 'My points'
  end

  example 'example XSS' do
    person.first_name = '<script>'
    rendered = show(person, balances: [], use_name: true)

    expect(rendered.to_s).to include 'Add new balance for &lt;script&gt;'
    expect(rendered.to_s).to include "&lt;script&gt;'s points"
  end
end
