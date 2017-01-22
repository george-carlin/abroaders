require 'rails_helper'

RSpec.describe Card::Operations::Edit do
  let(:account) { create(:account) }
  let(:op) { described_class }
  let(:card) { create(:card, closed_at: nil, person: account.owner) }

  describe 'prepopulation' do
    it 'sets "closed" correctly' do
      contract = op.({ id: card.id }, 'current_account' => account)['contract.default']
      contract.prepopulate!
      expect(contract.closed).to be false

      card.update!(closed_at: Date.today)
      contract = op.({ id: card.id }, 'current_account' => account)['contract.default']
      contract.prepopulate!
      expect(contract.closed).to be true
    end
  end
end
