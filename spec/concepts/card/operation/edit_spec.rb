require 'rails_helper'

RSpec.describe Card::Operation::Edit do
  let(:account) { create(:account) }
  let(:op) { described_class }
  let(:card) { create_card(person: account.owner) }

  describe 'prepopulation' do
    it 'sets "closed" correctly' do
      contract = op.({ id: card.id }, 'account' => account)['contract.default']
      contract.prepopulate!
      expect(contract.closed).to be false

      card.update!(closed_on: Date.today) # USEOP
      contract = op.({ id: card.id }, 'account' => account)['contract.default']
      contract.prepopulate!
      expect(contract.closed).to be true
    end
  end
end
