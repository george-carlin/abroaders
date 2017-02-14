require 'cells_helper'

RSpec.describe AdminArea::Person::Cell::SpendingInfo do
  controller AdminArea::PeopleController

  let(:account) { Account.new(monthly_spending_usd: 1234) }
  let(:person) { Person.new(id: 1, account: account) }

  example 'when person has no spending info' do
    expect(show(person).raw).to eq 'User has not added their spending info'
  end

  example 'when person has spending info' do
    person.spending_info = build(:spending_info, person: nil)
    rendered = show(person)
    expect(rendered).not_to have_content 'User has not added their spending info'
    expect(rendered).to have_link 'Edit'
  end
end
