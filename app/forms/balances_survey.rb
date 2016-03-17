# Note: This class was created before I invented the 'Form' abstraction. As
# such, it works very differently from the other '*Survey' classes in app/forms.
# I attempted to refactor it to make things more consistent, but decided it
# wasn't worth the trouble.
class BalancesSurvey

  attr_reader :balances, :errors

  def initialize(passenger, balances_params=nil)
    @passenger = passenger
    raise_unless_at_correct_onboarding_stage!
    if balances_params
      # If the user has types in values with commas, make sure that Ruby
      # treats this as the correct number:
      balances_params.each { |balance| balance[:value].try :gsub!, /,/, '' }
      # if the value they submitted is '0', or if they left the text field
      # empty, then don't create a Balance object, but don't make the whole
      # form submission fail. If they submitted a value that's less than 0,
      # then this is a validation error, so don't create anything, and show the
      # form again.
      balances_params.reject! do |balance|
        balance[:value].blank? || balance[:value].to_i == 0
      end
      @balances = @passenger.balances.build(balances_params).to_a
    else
      @balances = Currency.order("name ASC").map do |currency|
        @passenger.balances.build(currency: currency)
      end.to_a
    end
  end


  def save
    if valid?
      ApplicationRecord.transaction do
        @balances.each { |balance| balance.save(validate: false) }
        @passenger.account.onboarding_stage = next_stage
        @passenger.account.save!(validate: false)
        true
      end
    else
      @errors = @balances.flat_map do |balance|
        balance.errors.full_messages.map do |message|
          "#{balance.currency_name} #{message.downcase}"
        end
      end
      # Build balances for other currencies so they appear on the form:
      Currency.all.each do |currency|
        unless @balances.find { |b| b.currency_id == currency.id }
          @balances.push(@passenger.balances.build(currency: currency))
        end
      end
      @balances.sort_by! { |b| b.currency_name }
      false
    end
  end

  def valid?
    # Don't use 'all?' because we want to check *every* balance, so that every
    # invalid balance gets its error messages generated.
    result = true
    @balances.each { |b| result = false unless b.valid? }
    result
  end

  private

  # Sanity check to make sure we're at the right stage of the survey:
  def raise_unless_at_correct_onboarding_stage!
    onboarding_stage = @passenger.account.onboarding_stage
    if @passenger.main?
      raise unless onboarding_stage == "main_passenger_balances"
    else
      raise unless onboarding_stage == "companion_balances"
    end
  end

  def next_stage
    if @passenger.main? && @passenger.account.has_companion?
      "companion_balances"
    else
      "onboarded"
    end
  end
end
