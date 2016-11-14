require_relative "./card_account_on_page"

class NudgeableCardAccountOnPage < CardAccountOnPage
  button :approved,     "My application was approved"
  button :denied,       "My application was denied"
  button :pending,      "I'm still waiting to hear back"
  button :i_heard_back, proc { "I heard back from #{card_account.product.bank.name} by mail or email" }
end
