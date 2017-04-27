require 'types'

CreditScore = Types::Strict::Int.constrained(gteq: 350, lteq: 850)

def CreditScore.min
  rule.rules[-1].rules.find { |r| r.predicate.name == :gteq? }.options[:args][0]
end

def CreditScore.max
  rule.rules[-1].rules.find { |r| r.predicate.name == :lteq? }.options[:args][0]
end
