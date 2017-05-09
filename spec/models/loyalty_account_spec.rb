require 'rails_helper'

RSpec.describe LoyaltyAccount do
  describe '.build' do
    let(:person) { Person.new(id: 2, first_name: 'Erik') }
    let(:updated_at) { Time.new(2016, 12, 31, 12, 55, 32) }

    context 'for a Balance' do
      let(:balance) do
        Balance.new(
          id: 1,
          person: person,
          updated_at: updated_at,
          value: 12345,
          currency: Currency.new(name: 'American Airlines'),
        )
      end

      example '.build' do
        acc = described_class.build(balance)
        expect(acc.id).to eq 1
        expect(acc.person_id).to eq 2
        expect(acc.updated_at).to eq updated_at
        expect(acc.balance_raw).to eq 12345
        expect(acc.currency_name).to eq 'American Airlines'
        expect(acc.source).to eq 'abroaders'
        expect(acc.owner_name).to eq 'Erik'
      end

      example '#login' do
        acc = described_class.build(balance)
        expect(acc.login).to eq ''
      end

      example '#expiration_date' do
        acc = described_class.build(balance)
        expect(acc.expiration_date).to be_nil
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
          award_wallet_owner: AwardWalletOwner.new(name: 'Jorge', person: person),
          updated_at: updated_at,
        ).tap do |account| # damn you, ActiveRecord
          allow(account).to receive(:person).and_return(person)
        end
      end

      example '.build' do
        acc = described_class.build(awa)
        expect(acc.id).to eq 1
        expect(acc.person_id).to eq 2
        expect(acc.updated_at).to eq updated_at
        expect(acc.balance_raw).to eq 12345
        expect(acc.currency_name).to eq 'American Airlines'
        expect(acc.source).to eq 'award_wallet'
        expect(acc.login).to eq 'GeorgeMillo'
        expect(acc.expiration_date).to eq now
        expect(acc.owner_name).to eq 'Jorge'
      end
    end
  end
end
