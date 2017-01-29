require 'rails_helper'

RSpec.describe AdminArea::Account::Cell::Index, type: :view do
  describe described_class::TableRow do
    def cell(account)
      described_class.(account, context: CELL_CONTEXT).show
    end

    describe 'person links and readiness status labels' do
      let(:account) { create(:account) }
      let(:owner)   { account.owner }

      example 'ineligible owner' do
        raise unless !owner.eligible? && !owner.ready? # sanity check
        expect(cell(account)).to have_link(owner.first_name, exact: true)
      end

      example 'eligible & unready owner' do
        owner.update!(eligible: true, ready: false)
        expect(cell(account)).to have_link("#{owner.first_name} (E)", exact: true)
      end

      example 'ready owner' do
        owner.update!(eligible: true, ready: true)
        expect(cell(account)).to have_link("#{owner.first_name} (R)", exact: true)
      end
    end
  end
end
