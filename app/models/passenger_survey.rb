class PassengerSurvey

  PASSENGER_ATTRS = %i[
    first_name
    middle_names
    last_name
    phone_number
    whatsapp
    text_message
    imessage
    time_zone
    citizenship
    credit_score
    will_apply_for_loan
    personal_spending
    has_business
  ]

  attr_accessor :main_passenger, :companion

  accepts_nested_attributes_for :main_passenger, :companion

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def initialize(account, passengers_params=nil)
    @account = account
    @params  = passengers_params
  end

end
