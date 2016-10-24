class TravelPlanForm < ApplicationForm
  attribute :account,   Account
  # For 'from' and 'to', the user will submit a string like "London Heathrow
  # (LHR)", which is filled in by the typeahead.js plugin. From this string we
  # parse the airport code (in this case 'LHR') using a regex and find the
  # right airport in that way. Previously we were saving the code in a hidden
  # field that got updated by JS listening to custom events from the typeahead
  # plugin, but it didn't work in some edge cases.
  attribute :from,      String
  attribute :to,        String
  attribute :type,      String, default: "return"
  attribute :no_of_passengers,            Integer
  attribute :will_accept_economy,         Boolean, default: false
  attribute :will_accept_premium_economy, Boolean
  attribute :will_accept_business_class,  Boolean, default: false
  attribute :will_accept_first_class,     Boolean, default: false
  # Call these '*_date' rather than '*_on' (which are the names of the
  # underlying DB column) so that we get friendly error messages
  attribute :departure_date, Date
  attribute :return_date,    Date
  attribute :further_information, String

  def self.model_name
    TravelPlan.model_name
  end

  def self.types
    ::TravelPlan.types.slice("single", "return")
  end

  US_DATE_FORMAT = "%m/%d/%Y".freeze
  US_DATE_REGEX = /\A\s*(?:0?[1-9]|1[0-2])\/(?:0?[1-9]|[1-2]\d|3[01])\/\d{4}\s*\Z/

  def us_date_format?(date)
    !!(date =~ US_DATE_REGEX)
  end

  def departure_date_str
    if departure_date.is_a? Date
      departure_date.strftime(US_DATE_FORMAT)
    elsif departure_date.nil?
      ""
    else
      departure_date
    end
  end

  def departure_date=(new_date)
    if new_date.is_a?(String) && us_date_format?(new_date)
      super(Date.strptime(new_date.strip, US_DATE_FORMAT))
    else
      super
    end
  end

  def return_date_str
    if return_date.is_a? Date
      return_date.strftime(US_DATE_FORMAT)
    elsif return_date.nil?
      ""
    else
      return_date
    end
  end

  def return_date=(new_date)
    if new_date.is_a?(String) && us_date_format?(new_date)
      super(Date.strptime(new_date.strip, US_DATE_FORMAT))
    else
      super
    end
  end

  def owner_name(suffix = false)
    suffix = suffix ? "r" : ""
    "you#{suffix}"
  end

  concerning :Validations do
    included do
      with_options presence: true do
        validates :departure_date
        validates :from
        validates(
          :no_of_passengers,
          numericality: {
            greater_than_or_equal_to: 1,
            # avoid a duplicative error message when blank:
            allow_blank: true,
          },
        )
        validates :to
        validates :type, inclusion: { in: %w[single return] }
      end

      validates :return_date, presence: { if: :return? }, absence: { if: :single? }
      validates :further_information, length: { maximum: 500 }
      validate :departure_date_is_in_the_future
      validate :return_date_is_in_the_future
      validate :return_is_later_than_or_equal_to_departure
    end

    private

    def departure_date_is_in_the_future
      if departure_date.is_a?(Date)
        if departure_date < Date.today
          errors.add(:departure_date, "can't be in the past")
        end
      end
    end

    def return_date_is_in_the_future
      if return_date.is_a?(Date)
        if return_date < Date.today
          errors.add(:return_date, "can't be in the past")
        end
      end
    end

    def return_is_later_than_or_equal_to_departure
      if return_date.is_a?(Date)
        if departure_date.is_a?(Date) && return_date < departure_date
          errors.add(:return_date, "can't be earlier than departure date")
        end
      end
    end
  end

  private

  CODE_REGEX = /\(([A-Z]{3})\)\s*\z/

  def from_code
    CODE_REGEX.match(from)[1]
  end

  def to_code
    CODE_REGEX.match(to)[1]
  end

  def flight_attributes
    {
      from: Airport.find_by_code!(from_code),
      to:   Airport.find_by_code!(to_code),
    }
  end

  def travel_plan_attributes
    {
      acceptable_classes:   acceptable_classes,
      depart_on:            departure_date,
      further_information:  (further_information.strip if further_information.present?),
      no_of_passengers:     no_of_passengers,
      return_on:            return_date,
      type:                 type,
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

  def single?
    type == "single"
  end

  def return?
    type == "return"
  end

  # Technical debt alert: this is a duplicate of logic in
  # views/airports/index.json.erb
  def typeahead_name(airport)
    city_name = airport.parent.name

    displayed_name = "#{airport.name} (#{airport.code})"
    unless airport.name.downcase.include?(city_name.downcase)
      displayed_name = "#{city_name} #{displayed_name}"
    end
    displayed_name
  end
end
