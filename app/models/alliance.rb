# A grouping of currencies. Each Currency belongs to exactly one Alliance. In
# real life, some currencies don't belong to an alliance, and are considered
# independent. Here, we group those currencies under an 'alliance' called
# 'Independent' so we don't have to write a bunch of extra code treating 'no
# alliance' as a special case, e.g. in the currency filters on the 'admin
# recommend card' page. Essentially, the 'Independent' alliance is following
# the 'Null object' pattern.
class Alliance < ApplicationRecord
  has_many :currencies

  scope :in_order, -> { order(order: :asc) }
end
