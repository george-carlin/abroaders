require_relative "./card_account_on_page"

class NudgedCardAccountOnPage < CardAccountOnPage
  button :approved, "My application was approved"
  button :denied,   "My application was declined"
end
