require 'cells_helper'

RSpec.describe AdminArea::Accounts::Cell::Index do
  controller AdminArea::AccountsController

  describe described_class::TableRow do
    let(:account) { Account.new(id: 1, email: 'test@example.com', created_at: Time.zone.now) }
    let!(:owner)  { account.build_owner(id: 123, first_name: 'Erik') }

    example 'link to owner' do
      expect(show(account)).to have_link(owner.first_name, exact: true)
    end

    it 'avoids XSS' do
      account.build_owner(id: 1, first_name: '<evil>')
      account.build_companion(id: 2, first_name: '<knievel>')
      rendered = show(account).to_s
      expect(rendered).to include "&lt;evil&gt;"
      expect(rendered).to include "&lt;knievel&gt;"
    end
  end
end
