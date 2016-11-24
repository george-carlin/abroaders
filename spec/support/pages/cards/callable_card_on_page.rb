require_relative "./card_on_page"

class CallableCardOnPage < CardOnPage
  button :approved, "I was approved after reconsideration"
  button :pending,  "I'm being reconsidered, but waiting to hear back about whether it was successful"
  button :denied,   "My application is still denied"
end
