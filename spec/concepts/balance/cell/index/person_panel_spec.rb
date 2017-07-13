require 'cells_helper'

RSpec.describe Balance::Cell::Index::PersonPanel do
  let(:account) { Account.new }
  let(:person) { Person.new(account: account, owner: true, id: 1, first_name: 'Erik') }

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

  example '' do
    rendered = cell(person).()
    # test for link text EXACT match
    expect(rendered).to have_link 'Add new', href: new_person_balance_path(person)
    expect(rendered).to have_selector 'h1', text: 'My points'
  end

  example 'with no balances' do
    rendered = cell(person).()
    expect(rendered).to have_content 'No points balances'
  end

  example 'for a solo account' do
    rendered = cell(person).()
    expect(rendered).to have_link 'Add new'
    expect(rendered).to have_selector 'h1', text: 'My points'
  end

  example 'for a couples account' do
    couples!

    rendered = cell(person).()

    expect(rendered).to have_selector 'h1', text: "Erik's points"
    expect(rendered).to have_link 'Add new', href: new_person_balance_path(person)
  end

  example 'XSS' do
    couples!

    person.first_name = '<script>'
    expect(raw_cell(person)).to include "&lt;script&gt;'s points"
  end

  example 'not connected to award wallet' do
    rendered = cell(person).()
    expect(rendered).to have_link 'Add new', href: new_person_balance_path(person)
    expect(rendered).not_to have_button 'Add new'
  end

  example 'not connected to award wallet' do
    person.account.build_award_wallet_user(loaded: true)
    rendered = cell(person).()
    expect(rendered).not_to have_link 'Add new', href: new_person_balance_path(person)
    expect(rendered).to have_button 'Add new'
  end
end
