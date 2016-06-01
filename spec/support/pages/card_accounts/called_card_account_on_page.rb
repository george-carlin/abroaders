require_relative "./card_account_on_page"

class CalledCardAccountOnPage < CardAccountOnPage
  button :approved, "My application was approved after reconsideration"
  button :denied,   "My application is still denied"
end
