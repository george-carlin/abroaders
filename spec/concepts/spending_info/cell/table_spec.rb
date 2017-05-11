require 'cells_helper'

RSpec.describe SpendingInfo::Cell::Table do
  # Hmmmm.... this is kind of a code smell, that a basic view for displaying a
  # SpendingInfo should be so tightly coupled to the Info's Person and Account
  let(:account) { Account.new(monthly_spending_usd: 1000) }
  let(:person)  { Person.new(account: account) }

  let(:info) do
    person.build_spending_info(
      credit_score:          350,
      will_apply_for_loan:   wafl,
      business_spending_usd: business_spending,
      has_business:          has_business,
    )
  end

  before { account.build_companion if couples_account }

  let(:wafl)              { false }
  let(:business_spending) { 1500 }
  let(:has_business)      { 'with_ein' }
  let(:couples_account)   { false }

  let(:rendered) { cell(info).() }

  it '' do
    expect(rendered).to have_content 'Credit score: 350'
    expect(rendered).to have_content 'Will apply for loan in next 6 months: No'
    expect(rendered).to have_content 'Business spending: $1,500.00'
    expect(rendered).to have_content '(Has EIN)'
  end

  context 'for a solo account' do
    let(:couples_account) { false }
    specify 'spending is described as "personal spending"' do
      expect(rendered).to have_content 'Personal spending:$1,000'
    end
  end

  context 'for a couples account' do
    let(:couples_account) { true }
    specify 'spending is described as "shared spending"' do
      expect(rendered).to have_content 'Shared spending:$1,000'
    end
  end
end
