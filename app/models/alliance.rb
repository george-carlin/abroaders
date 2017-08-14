require 'types'

# A grouping of currencies. Each Currency belongs to exactly one Alliance. In
# real life, some currencies don't belong to an alliance, and are considered
# independent. Here, we group those currencies under an 'alliance' called
# 'Independent' so we don't have to write a bunch of extra code treating 'no
# alliance' as a special case, e.g. in the currency filters on the 'admin
# recommend card' page. Essentially, the 'Independent' alliance is following
# the 'Null object' pattern.
class Alliance < Dry::Struct
  Name = Types::Strict::String.enum(
    'OneWorld', 'StarAlliance', 'SkyTeam', 'Independent',
  )
  attribute :name, Name

  def id
    Inflecto.underscore(name)
  end

  def currencies
    Currency.where(alliance_name: name)
  end

  def self.all
    Name.options[:values].map { |n| new(name: n) }
  end
end
