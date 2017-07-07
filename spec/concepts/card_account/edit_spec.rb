require 'rails_helper'

RSpec.describe CardAccount::Edit do
  let(:account) { create_account }
  let(:op) { described_class }
  let(:card_account) { create_card_account(person: account.owner) }

  describe 'prepopulation' do
    it 'sets "closed" correctly' do
      contract = op.({ id: card_account.id }, 'current_account' => account)['contract.default']
      contract.prepopulate!
      expect(contract.closed).to be false

      card_account.update!(closed_on: Date.today) # USEOP
      contract = op.({ id: card_account.id }, 'current_account' => account)['contract.default']
      contract.prepopulate!
      expect(contract.closed).to be true
    end
  end
end
