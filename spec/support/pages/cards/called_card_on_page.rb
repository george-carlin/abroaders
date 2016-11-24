require_relative "./card_on_page"

class CalledCardOnPage < CardOnPage
  button :approved, "My application was approved after reconsideration"
  button :denied,   "My application is still denied"
end
