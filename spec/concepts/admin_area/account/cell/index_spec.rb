require 'cells_helper'

RSpec.describe AdminArea::Account::Cell::Index do
  controller AdminArea::AccountsController

  describe described_class::TableRow do
    describe 'person links and readiness status labels' do
      let(:account) { Account.new(id: 1, email: 'test@example.com', created_at: Time.zone.now) }
      let(:owner)   { account.build_owner(id: 123, first_name: 'Erik') }

      example 'ineligible owner' do
        raise unless !owner.eligible? && !owner.ready? # sanity check
        expect(show(account)).to have_link(owner.first_name, exact: true)
      end

      example 'eligible & unready owner' do
        owner.assign_attributes(eligible: true, ready: false)
        expect(show(account)).to have_link("#{owner.first_name} (E)", exact: true)
      end

      example 'ready owner' do
        owner.assign_attributes(eligible: true, ready: true)
        expect(show(account)).to have_link("#{owner.first_name} (R)", exact: true)
      end
    end
  end
end
