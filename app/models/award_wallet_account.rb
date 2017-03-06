# An account with a rewards program, as stored on AwardWallet
#
# Note that what we call a 'Balance', AW calls an 'Account', and what we call
# an 'Account', AW calls a 'User'.
class AwardWalletAccount < ApplicationRecord
  belongs_to :award_wallet_owner
end
