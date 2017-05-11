require 'cells_helper'

RSpec.describe Balance::Cell::Index::PersonPanel do
  controller BalancesController

  let(:person) { Person.new(owner: true, id: 1, first_name: 'Erik') }

  let(:couples!) { person.account.build_companion }

  let!(:current_account) { person.build_account }

  def new_balance(value)
    Balance.new(
      id: rand(100),
      currency: Currency.new(name: 'X'),
      updated_at: Time.now,
      value: value,
      person: person,
    )
  end

  def stub_person_balances(balances)
    allow(person).to receive(:balances).and_return(balances)
  end

  example '' do
    stub_person_balances([new_balance(123), new_balance(321)])
    rendered = cell(person).()
    # test for link text EXACT match
    expect(rendered).to have_link 'Add new', href: new_person_balance_path(person)
    expect(rendered).to have_selector 'h1', text: 'My points'
  end

  example 'with no balances' do
    stub_person_balances([])
    rendered = cell(person).()
    expect(rendered).to have_content 'No points balances'
  end

  example 'for a solo account' do
    stub_person_balances([])
    rendered = cell(person).()
    expect(rendered).to have_link 'Add new'
    expect(rendered).to have_selector 'h1', text: 'My points'
  end

  example 'for a couples account' do
    couples!

    stub_person_balances([])
    rendered = cell(person).()

    expect(rendered).to have_selector 'h1', text: "Erik's points"
    expect(rendered).to have_link 'Add new', href: new_person_balance_path(person)
  end

  example 'XSS' do
    couples!

    person.first_name = '<script>'
    stub_person_balances([])
    expect(raw_cell(person)).to include "&lt;script&gt;'s points"
  end
end
