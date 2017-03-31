# An account with a rewards program, as stored on AwardWallet
#
# Note that what we call a 'Balance', AW calls an 'Account', and what we call
# an 'Account', AW calls a 'User'.
class AwardWalletAccount < ApplicationRecord
  belongs_to :award_wallet_owner
  has_one :award_wallet_user, through: :award_wallet_owner
  has_one :person, through: :award_wallet_owner

  alias owner award_wallet_owner

  def owner_name
    owner.name
  end
end
