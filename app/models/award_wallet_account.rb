# An account with a rewards program, as stored on AwardWallet
#
# Note that what we call a 'Balance', AW calls an 'Account', and what we call
# an 'Account', AW calls a 'User'.
class AwardWalletAccount < ApplicationRecord
  belongs_to :award_wallet_owner
  has_one :award_wallet_user, through: :award_wallet_owner
  has_one :person, through: :award_wallet_owner

  alias owner award_wallet_owner

  alias_attribute :balance, :balance_raw

  delegate :id, to: :person, allow_nil: true, prefix: true
  delegate :name, to: :owner, prefix: true
end
