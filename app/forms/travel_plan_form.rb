class TravelPlanForm < ApplicationForm
  attribute :account,   Account
  attribute :from_code, String
  attribute :to_code,   String
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
  attribute :earliest_departure,  Date, default: lambda { |_, _| Date.today }
  attribute :further_information, String

  def self.model_name
    TravelPlan.model_name
  end

  def self.types
    ::TravelPlan.types.slice("single", "return")
  end

  US_DATE_FORMAT = "%m/%d/%Y".freeze

  def from_name
    ""
  end

  def to_name
    ""
  end

  def us_date_format?(date)
    date =~ /\A\s*(?:0?[1-9]|1[0-2])\/(?:0?[1-9]|[1-2]\d|3[01])\/\d{4}\s*\Z/
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

  # TODO this is display logic, doesn't belong in the Form object
  def show_skip_survey?
    true
  end

  # TODO this is display logic, doesn't belong in the Form object
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
        validates :departure_date
        validates :from_code
        validates(
          :no_of_passengers,
          numericality: {
            greater_than_or_equal_to: 1,
            # avoid a duplicative error message when blank:
            allow_blank: true,
          },
        )
        validates :to_code
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
          errors.add(:departure_date, "date can't be in the past")
        end
      end
    end

    def return_date_is_in_the_future
      if return_date.is_a?(Date)
        if return_date < Date.today
          errors.add(:return_date, "date can't be in the past")
        end
      end
    end

    def return_is_later_than_or_equal_to_departure
      if return_date.is_a?(Date)
        if departure_date.is_a?(Date) && return_date < departure_date
          errors.add(:return_date, "date can't be earlier than departure date")
        end
      end
    end
  end

  private

  def flight_attributes
    {
      from: Airport.find_by!(code: from_code),
      to:   Airport.find_by!(code: to_code),
    }
  end

  def travel_plan_attributes
    {
      type:                 type,
      depart_on:            departure_date,
      return_on:            return_date,
      further_information:  further_information&.strip,
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

  def single?
    type == "single"
  end

  def return?
    type == "return"
  end
end
