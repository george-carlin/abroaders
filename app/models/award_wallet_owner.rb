# The owner name associated with a specific AwardWalletAccount.
#
# Every AwardWalletAccount has an 'owner', which can either be a 'user' (a
# fully-fledged login account on AW.com, which we represent with the
# `AwardWalletUser` class) or a 'member' (just a name which the user adds on
# their AW dashboard.)
#
# 'owners' don't appear to be fully separate entity in the AW API; in the JSON
# we get from the API, the 'owner' is just a 'string' attribute of ecahjk\w
#
class AwardWalletOwner < ApplicationRecord
  belongs_to :award_wallet_user
  belongs_to :person, optional: true
  has_many :award_wallet_accounts
end
