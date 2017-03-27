require 'cells_helper'

# FIXME these specs need updating for the refactored BalanceTable
RSpec.describe Balance::Cell::BalanceTable do
  before { pending }

  let(:account) { Account.new }
  let(:balance_class) { Struct.new(:id) }
  let(:person) { account.build_owner(id: 1, first_name: 'Erik') }

  def stub_person_balances(balances)
    allow(person).to receive(:balances).and_return(balances)
  end

  example '' do
    stub_person_balances([balance_class.new(123), balance_class.new(321)])
    rendered = show(person)
    # test for link text EXACT match
    expect(rendered).to have_xpath("//a[text()='Add new']")
    expect(rendered).to have_content 'Balance 123'
    expect(rendered).to have_content 'Balance 321'
    expect(rendered).to have_selector 'h1', text: 'My points'
  end

  example 'with no balances' do
    stub_person_balances([])
    rendered = show(person)
    expect(rendered).to have_content 'No balances'
  end

  example 'with use_name: true' do
    stub_person_balances([])
    rendered = show(person, use_name: true)

    expect(rendered).to have_link 'Add new balance for Erik'
    expect(rendered).to have_selector 'h1', text: "Erik's points"
  end

  example 'with use_name: false' do
    stub_person_balances([])
    rendered = show(person, use_name: false)
    # text for link text EXACT match:
    expect(rendered).to have_xpath("//a[text()='Add new']")
    expect(rendered).to have_selector 'h1', text: 'My points'
  end

  example 'XSS' do
    person.first_name = '<script>'
    stub_person_balances([])
    rendered = show(person, use_name: true)

    expect(rendered.to_s).to include 'Add new balance for &lt;script&gt;'
    expect(rendered.to_s).to include "&lt;script&gt;'s points"
  end
end
