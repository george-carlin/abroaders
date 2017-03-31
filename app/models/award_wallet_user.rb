# A user account on AwardWallet.com.
#
# Confusingly, what we call an 'account', AW calls a 'user', and what we call a
# 'balance' AW calls an 'account'.
#
# When AWUsers are first created, we don't know anything about them except the
# Abroaders account that they correspond to, and the AW userId (which we store
# as `aw_id`). In this state, the user is "unloaded". After the AWUser has been
# created from the API callback, a BG job is scheduled that queries the AW API
# and gets the rest of the AWUser's data. The BG job then saves this data into
# our DB, and the AWUser's `loaded` attribute is permanently set to `true`.
class AwardWalletUser < ApplicationRecord
  belongs_to :account

  has_many :award_wallet_owners
  has_many :award_wallet_accounts, through: :award_wallet_owners
end
