class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # We're deviating from The Rails Way™ (gasp!) by keeping validations out
  # of our ActiveRecord models and leaving them for the form layer (i.e.  TRB
  # ops + Reform.) This means we can afford to be defensive and disallow
  # invalid state from being set in the first place, because Invalid Object Is
  # An Anti-Pattern:
  #
  # http://solnic.eu/2015/12/28/invalid-object-is-an-anti-pattern.html
  #
  # We don't need to go overboard and set this for every single attribute,
  # but where appropriate you can use this with dry-types:
  #
  #     CreditScore = Types::Strict::Int.constrained(gteq: 350, lteq: 850)
  #
  #     class SpendingInfo < ApplicationRecord
  #       attribute_type :credit_score, CreditScore
  #     end
  #
  #     SpendingInfo.new(credit_score: 349)
  #     # => Dry::Types::ConstraintError
  #     SpendingInfo.new(credit_score: 851)
  #     # => Dry::Types::ConstraintError
  #     SpendingInfo.new(credit_score: 850)
  #     # => #<SpendingInfo credit_score: 850>
  def self.attribute_type(attr_name, type)
    define_method "#{attr_name}=" do |new_value|
      super(type.(new_value))
    end
  end

  def self.enum(*)
    raise NotImplementedError, "don't use ActiveRecord::Enum"
  end
end
