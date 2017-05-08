require 'rails_helper'

RSpec.describe LoyaltyAccount do
  describe '.build' do
    let(:updated_at) { Time.new(2016, 12, 31, 12, 55, 32) }

    context 'for a Balance' do
      let(:balance) do
        Balance.new(
          id: 1,
          person_id: 2,
          updated_at: updated_at,
          value: 12345,
          currency: Currency.new(name: 'American Airlines'),
        )
      end

      it '' do
        acc = described_class.build(balance)
        expect(acc.id).to eq 1
        expect(acc.person_id).to eq 2
        expect(acc.updated_at).to eq updated_at
        expect(acc.balance_raw).to eq 12345
        expect(acc.currency_name).to eq 'American Airlines'
        expect(acc.source).to eq 'abroaders'
      end
    end

    context 'for an AwardWalletAccount' do
      let(:now) { Time.now }

      let(:awa) do
        ::AwardWalletAccount.new(
          id: 1,
          aw_id: 555,
          balance_raw: 12345,
          display_name: 'American Airlines',
          expiration_date: now,
          login: 'GeorgeMillo',
          award_wallet_owner: AwardWalletOwner.new(person: Person.new(id: 2)),
          updated_at: updated_at,
        )
      end

      it '' do
        acc = described_class.build(awa)
        expect(acc.id).to eq 1
        # expect(acc.person_id).to eq 2
        expect(acc.updated_at).to eq updated_at
        expect(acc.balance_raw).to eq 12345
        expect(acc.currency_name).to eq 'American Airlines'
        expect(acc.source).to eq 'award_wallet'
        expect(acc.login).to eq 'GeorgeMillo'
        expect(acc.expiration_date).to eq now
      end
    end
  end
end
