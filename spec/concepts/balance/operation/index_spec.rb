require 'rails_helper'

RSpec.describe Balance::Operation::Index do
  let(:op) { described_class }

  example 'couples account' do
    account   = create(:account, :couples)
    owner     = account.owner
    companion = account.companion

    result = op.({}, 'account' => account)
    expect(result['people']).to eq [owner, companion]
  end
end
