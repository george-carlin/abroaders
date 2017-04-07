require 'cells_helper'

RSpec.describe AdminArea::Accounts::Cell::Index do
  controller AdminArea::AccountsController

  describe described_class::TableRow do
    let(:account) { Account.new(id: 1, email: 'test@example.com', created_at: Time.zone.now) }
    let(:owner)   { account.build_owner(id: 123, first_name: 'Erik') }

    example 'link to owner' do
      expect(show(account)).to have_link(owner.first_name, exact: true)
    end
  end
end
