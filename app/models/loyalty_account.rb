require 'dry-struct'
require 'active_support/core_ext/hash/keys'
require 'declarative/builder'

require 'types'

# Wrapper class that presents a common interface for both Balances and
# AwardWalletAccounts in places where they are used more-or-less
# interchangeably, e.g. when listing a person's loyalty accounts on
# Balances#index
#
# Use LoyaltyAccount.build to create a LoyaltyAccount from a Balances or an
# AwardWalletAccount, using the correct subclass of LoyaltyAccount
class LoyaltyAccount < Dry::Struct
  include Declarative::Builder

  builds do |balance_or_awa|
    next AwardWallet if balance_or_awa.is_a?(AwardWalletAccount)
    Abroaders
  end

  def self.build(*args)
    build!(self, *args).build(*args)
  end

  attribute :id, Types::Strict::Int
  attribute :person_id, Types::Strict::Int
  attribute :currency_name, Types::Strict::String
  attribute :balance_raw, Types::Strict::Int
  attribute :updated_at, Types::Strict::DateTime

  class Abroaders < self
    def self.build(balance)
      attrs = balance.attributes.symbolize_keys.slice(:id, :person_id)
      attrs[:balance_raw]   = balance.value
      attrs[:currency_name] = balance.currency_name
      attrs[:updated_at] = balance.updated_at.to_datetime
      new(attrs)
    end

    def source
      'abroaders'
    end
  end

  class AwardWallet < self
    attribute :award_wallet_id, Types::Strict::Int
    attribute :login, Types::Strict::String

    def self.build(awa)
      attrs = awa.attributes.symbolize_keys.slice(:id, :balance_raw, :updated_at, :login)
      attrs[:award_wallet_id] = awa.aw_id
      attrs[:currency_name]   = awa.display_name
      attrs[:person_id]       = awa.award_wallet_owner.person.id
      attrs[:updated_at]      = awa.updated_at.to_datetime
      new(attrs)
    end

    def source
      'award_wallet'
    end
  end
end
