require_relative './card_on_page'

class NudgedCardOnPage < CardOnPage
  button :approved, "My application was approved"
  button :denied,   "My application was declined"
end
