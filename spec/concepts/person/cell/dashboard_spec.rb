require 'rails_helper'

RSpec.describe Person::Cell::Dashboard, type: :view do
  let(:account) { create(:account, :onboarded) }
  let(:person)  { account.owner }

  # remember that the user won't be able to see the dashboard until they've
  # completed the onboarding survey and, if they're eligible, received recs.

  subject(:cell) { described_class.(person, context: CELL_CONTEXT).show }

  it { is_expected.to have_selector 'h3', text: person.first_name }

  context 'when person is eligible' do
    before do
      person.update!(eligible: true)
      create(:spending_info, person: person)
      person.reload
    end

    example 'spending info' do
      expect(cell).to have_content person.spending_info.credit_score
    end
  end

  context 'when person is eligible' do
    before { raise if person.eligible? } # sanity check

    it { is_expected.to have_content 'Ineligible to apply for cards' }
  end

  example 'balances'
  example 'cards'
end
