require_relative "./card_account_on_page"

class PostNudgeCardAccountOnPage < CardAccountOnPage
  button :i_heard_back, "I heard back from the bank"
  button :approved, "My application was approved"
  button :denied,   "My application was declined"
end
