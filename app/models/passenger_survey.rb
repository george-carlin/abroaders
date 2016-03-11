class PassengerSurvey

  PASSENGER_ATTRS = %i[
    first_name
    middle_names
    last_name
    phone_number
    whatsapp
    text_message
    imessage
    citizenship
    willing_to_apply
  ]

  attr_accessor :account, :main_passenger, :companion, :has_companion

  def has_companion?
    self.has_companion
  end

  delegate :shares_expenses, :shares_expenses=, :time_zone, :time_zone=,
            to: :account
  delegate(*PASSENGER_ATTRS, to: :main_passenger, prefix: true)
  delegate(*PASSENGER_ATTRS, to: :companion, prefix: true)

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def initialize(account, params=nil)
    account.build_main_passenger if account.main_passenger.nil?
    account.build_companion      if account.companion.nil?
    self.main_passenger = account.main_passenger
    self.companion      = account.companion

    if params
      self.has_companion   = params[:has_companion]

      if mpp = params.delete(:main_passenger_attributes)
        account.main_passenger.assign_attributes(mpp)
      end
      if has_companion? && cop = params.delete(:companion_attributes)
        account.companion.assign_attributes(cop)
      end
      account.assign_attributes(params)
    end

    self.account = account

    if params
      self.time_zone       = params[:time_zone]
      self.shares_expenses = params[:shares_expenses]
    end
  end

  def save
    Passenger.transaction do
      if valid?
        unless has_companion?
          # Remove the blank Passenger that was created earlier by
          # `build_companion` - otherwise `account.save` will attempt to save
          # it with invalid attributes, raising an error.
          self.account.companion = nil
        end
        self.account.save(validate: false)
        true
      else
        false
      end
    end
  end

  # Validations

  validates :time_zone, presence: true

  validates :main_passenger_first_name,   presence: true
  validates :main_passenger_last_name,    presence: true
  validates :main_passenger_phone_number, presence: true

  validates :companion_first_name,   presence: { if: :has_companion? }
  validates :companion_last_name,    presence: { if: :has_companion? }
  validates :companion_phone_number, presence: { if: :has_companion? }

  validate :at_least_one_passenger_is_willing_to_apply, if: :has_companion?

  # TODO validate phone number looks like a valid phone number
  # TODO strip leading/trailing whitespace from string cols

  private

  def at_least_one_passenger_is_willing_to_apply
    if !(main_passenger.willing_to_apply? || companion.willing_to_apply)
      errors.add(:base, "At least one passenger must be willing to apply")
    end
  end
end
