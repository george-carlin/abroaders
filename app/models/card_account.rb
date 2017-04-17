# placeholder class. This will shortly be turned into a full-fledged
# ActiveRecord model backs by a DB table called 'card_accounts'. In the
# meantime, use a PORO with some fake ActiveRecord-like functionality to aid in
# the transition
class CardAccount
  def self.count
    Card.accounts.count
  end

  def self.find(id)
    Card.accounts.find(id)
  end

  def self.new(*args)
    Card.new(*args)
  end
end
