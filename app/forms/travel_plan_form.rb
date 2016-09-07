class TravelPlanForm < ApplicationForm
  attribute :account, Account
  attribute :from_id, Integer
  attribute :to_id,   Integer
  attribute :type,    String, default: "return"
  attribute :no_of_passengers,            Integer, default: 1
  attribute :will_accept_economy,         Boolean, default: false
  attribute :will_accept_premium_economy, Boolean
  attribute :will_accept_business_class,  Boolean, default: false
  attribute :will_accept_first_class,     Boolean, default: false
  attribute :earliest_departure,  Date,  default: lambda { |_, _| Date.today }
  attribute :further_information, String

  def self.name
    "TravelPlan"
  end

  def self.types
    ::TravelPlan.types.slice("single", "return")
  end

  US_DATE_FORMAT = "%m/%d/%Y"

  def earliest_departure_str
    earliest_departure.strftime(US_DATE_FORMAT)
  end

  def earliest_departure=(new_date)
    if new_date.is_a?(String)
      super(Date.strptime(new_date.strip, US_DATE_FORMAT))
    else
      super
    end
  end

  def show_skip_survey?
    true
  end

  def show_earliest_departure_help_block?
    true
  end

  def form_object
    self
  end

  def owner_name(suffix = false)
    suffix = suffix ? "r" : ""
    "you#{suffix}"
  end

  concerning :Validations do
    included do
      with_options presence: true do
        validates :earliest_departure
        validates :from_id
        validates :no_of_passengers,
          numericality: { greater_than_or_equal_to: 1 }
        validates :to_id
        validates :type, inclusion: { in: %w[single return] }
      end

      validates :further_information, length: { maximum: 500 }
      validate :earliest_departure_is_in_the_future
    end

    private

    def earliest_departure_is_in_the_future
      if earliest_departure && earliest_departure < Date.today
        errors.add(:earliest_departure, "can't be in the past")
      end
    end
  end

  private

  def flight_attributes
    {
      from: Destination.country.find(from_id),
      to:   Destination.country.find(to_id),
    }
  end

  def travel_plan_attributes
    {
      type:                 type,
      departure_date_range: earliest_departure..earliest_departure,
      further_information:  further_information.strip,
      no_of_passengers:     no_of_passengers,
      acceptable_classes:   acceptable_classes,
    }
  end

  def acceptable_classes
    [
      (:economy         if will_accept_economy?),
      (:premium_economy if will_accept_premium_economy?),
      (:business_class  if will_accept_business_class?),
      (:first_class     if will_accept_first_class?),
    ].compact
  end

end
