class TravelPlanForm < ApplicationForm
  attribute :account, Account
  attribute :from_id, Integer
  attribute :to_id,   Integer
  attribute :type,    String, default: "return"
  attribute :no_of_passengers,            Integer
  attribute :will_accept_economy,         Boolean, default: false
  attribute :will_accept_premium_economy, Boolean
  attribute :will_accept_business_class,  Boolean, default: false
  attribute :will_accept_first_class,     Boolean, default: false
  attribute :depart_on, Date
  attribute :return_on, Date
  attribute :further_information, String

  def self.name
    "TravelPlan"
  end

  def self.types
    ::TravelPlan.types.slice("single", "return")
  end

  US_DATE_FORMAT = "%m/%d/%Y"

  def us_date_format?(date)
    date =~ /\A\s*(?:0?[1-9]|1[0-2])\/(?:0?[1-9]|[1-2]\d|3[01])\/\d{4}\s*\Z/
  end

  def departure_date_str
    if depart_on.is_a? Date
      depart_on.strftime(US_DATE_FORMAT)
    elsif depart_on.nil?
      ""
    else
      depart_on
    end
  end

  def depart_on=(new_date)
    if new_date.is_a?(String) && us_date_format?(new_date)
      super(Date.strptime(new_date.strip, US_DATE_FORMAT))
    else
      super
    end
  end

  def return_date_str
    if return_on.is_a? Date
      return_on.strftime(US_DATE_FORMAT)
    elsif return_on.nil?
      ""
    else
      return_on
    end
  end

  def return_on=(new_date)
    if type == "single"
      super(nil)
    elsif new_date.is_a?(String) && us_date_format?(new_date)
      super(Date.strptime(new_date.strip, US_DATE_FORMAT))
    else
      super
    end
  end

  def show_skip_survey?
    true
  end

  def show_departure_date_help_block?
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
        validates :depart_on
        validates :from_id
        validates :no_of_passengers,
                  numericality: { greater_than_or_equal_to: 1 }
        validates :to_id
        validates :type, inclusion: { in: %w[single return] }
      end

      validates :further_information, length: { maximum: 500 }
      validate :departure_date_is_in_the_future
      validate :return_date_later_than_or_equal_departure_date
    end

    private

    def departure_date_is_in_the_future
      if depart_on.is_a?(Date)
        if depart_on < Date.today
          errors.add(:depart_on, "date can't be in the past")
        end
      else
        errors.add(:depart_on, "date must be date with correct format")
      end
    end

    def return_date_later_than_or_equal_departure_date
      if return_on.is_a?(Date)
        if depart_on.is_a?(Date) && return_on < depart_on
          errors.add(:return_on, "date can't be earlier than departure date")
        end
      else
        if return_on.nil?
          errors.add(:return_on, "date must be specified for round trip") if type == "return"
        else
          errors.add(:return_on, "date must be date with correct format")
        end
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
      depart_on:            depart_on,
      return_on:            return_on,
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
