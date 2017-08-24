require 'constants'
require 'types'

# model: a Person
class Balance::Survey < Reform::Form
  feature Coercion

  CurrencyId = ::Dry::Types::Definition.new(Integer).constructor do |id|
    # raise an error if the currency doesn't exist:
    Currency.find(Types::Form::Int.(id)).id
  end

  collection(
    :balances,
    populate_if_empty: Balance,
    prepopulator: :prepopulate_balances!,
  ) do
    property :present, virtual: true
    property :currency_id, type: CurrencyId
    property :value, type: Types::Form::Int # TODO allows commas?

    validates :value,
              numericality: {
                greater_than_or_equal_to: 0,
                less_than_or_equal_to: PSQL_MAX_INT,
              },
              presence: true
  end

  def save(*)
    super.tap do
      onboarder = Account::Onboarder.new(model.account)
      if model.owner?
        onboarder.add_owner_balances!
      else
        onboarder.add_companion_balances!
      end
    end
  end

  def prepopulate_balances!(*_args)
    currencies.each do |currency|
      self.balances << model.balances.build(currency: currency)
    end
  end

  # hackhackhackhack :(
  def repopulate!
    existing_bals = self.balances.dup
    self.balances = []
    currencies.each do |currency|
      self.balances.append(model.balances.build(currency: currency))

      if (existing = existing_bals.detect { |b| b.currency_id == currency.id })
        self.balances[-1].present = true
        self.balances[-1].value = existing.value
      end
    end
  end

  def currencies
    Currency.survey.order(name: :asc)
  end
end
