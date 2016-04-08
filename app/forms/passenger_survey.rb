class PassengerSurvey < Form

  def initialize(account)
    raise unless account.onboarding_stage == "passengers"

    account.build_main_passenger if account.main_passenger.nil?
    account.build_companion      if account.companion.nil?

    @account       = account
    @has_companion = false

    # Initialize the default values as provided by ActiveRecord:
    PASSENGER_ATTRS.each do |attr|
      send :"main_passenger_#{attr}=", @account.main_passenger.send(attr)
      send :"companion_#{attr}=", @account.companion.send(attr)
    end
    self.shares_expenses = @account.shares_expenses
  end

  # ---- Attributes ----

  attr_accessor :shares_expenses, :has_companion
  alias_method :has_companion?, :has_companion

  PASSENGER_ATTRS = %i[
    first_name
    phone_number
    whatsapp
    text_message
    imessage
    citizenship
    willing_to_apply
  ]

  PASSENGER_ATTRS.each do |attr|
    attr_accessor :"main_passenger_#{attr}", :"companion_#{attr}"
  end

  attr_boolean_accessor :has_companion

  # ----- Persistence -----

  def save
    super do
      @account.shares_expenses  = shares_expenses
      @account.onboarding_stage = "spending"

      PASSENGER_ATTRS.each do |attr|
        @account.main_passenger.send(
          :"#{attr}=",
          send(:"main_passenger_#{attr}")
        )
      end
      if has_companion?
        PASSENGER_ATTRS.each do |attr|
          @account.companion.send :"#{attr}=", send(:"companion_#{attr}")
        end
      else
        # Remove the blank Passenger that was created earlier by
        # `build_companion` - otherwise `account.save` will attempt to save
        # it with invalid attributes, raising an error.
        @account.companion = nil
      end
      # As well as saving the account, this  will automatically save the
      # associated passenger(s):
      @account.save!(validate: false)
    end
  end

  # Validations

  validates :main_passenger_first_name,
    length: { maximum: Passenger::NAME_MAX_LENGTH }, presence: true
  validates :main_passenger_phone_number,
    length: { maximum: Passenger::PHONE_MAX_LENGTH }, presence: true

  with_options if: :has_companion? do
    validates :companion_first_name,
     length: { maximum: Passenger::NAME_MAX_LENGTH }, presence: true
    validates :companion_phone_number,
      length: { maximum: Passenger::PHONE_MAX_LENGTH }, presence: true
  end

  validate :at_least_one_passenger_is_willing_to_apply, if: :has_companion?

  private

  def at_least_one_passenger_is_willing_to_apply
    if !(@account.main_passenger.willing_to_apply? ||
        @account.companion.willing_to_apply)
      errors.add(:base, "At least one passenger must be willing to apply")
    end
  end
end
