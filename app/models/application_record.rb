class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # the default new app sets this to 'true' in an initializer, but for some
  # reason it was only being set in dev/prod and not tests. Something to do
  # with another gem (devise?) loading AR too early, see
  # https://github.com/rails/rails/issues/23589 and /27844
  #
  # Setting the config option in here rather than the initializer ensures that
  # the setting is consistent in all envs and we have dev/prod parity.
  self.belongs_to_required_by_default = true

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
