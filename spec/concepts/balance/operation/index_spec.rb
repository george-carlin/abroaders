require 'rails_helper'

RSpec.describe Balance::Operation::Index do
  let(:op) { described_class }

  example 'couples account' do
    account   = create(:account, :couples)
    owner     = account.owner
    companion = account.companion

    result = op.({}, 'account' => account)
    # must have people as keys even when they have no balances (bug fix)
    expect(result['people_with_balances'].keys).to eq [owner, companion]
  end
end
