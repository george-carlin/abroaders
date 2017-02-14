require 'cells_helper'

RSpec.describe Account::Cell::Dashboard::Person do
  controller AccountsController

  let(:account) { Account.new }
  let(:person)  { account.build_owner(id: 1, first_name: 'Erik') }

  before { person.account = account }

  subject(:rendered) { show(person) }

  it { is_expected.to have_selector 'h3', text: person.first_name }

  example 'for eligible person' do
    person.eligible = true
    person.build_spending_info(credit_score: 567)
    expect(rendered).to have_content '567'
  end

  example 'for ineligible person' do
    raise if person.eligible? # sanity check
    expect(rendered).to have_content 'Ineligible to apply for cards'
  end

  example 'XSS protection' do
    person.first_name = '<script>alert()</script>'
    expect(rendered.raw).to include '&lt;script&gt;alert()&lt;/script&gt;'
  end
end
