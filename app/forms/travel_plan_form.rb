class TravelPlanForm < Form

  attr_accessor :earliest_departure,
                :from_id,
                :further_information,
                :no_of_passengers,
                :to_id,
                :type

  DATE_REGEX = /\d{1,2}\/\d{1,2}\/\d\d\d\d/

  attr_boolean_accessor :will_accept_economy,
                        :will_accept_premium_economy,
                        :will_accept_business_class,
                        :will_accept_first_class

  # Returns earliest_departure as a Date, not a String
  def earliest_departure_as_date
    if earliest_departure && earliest_departure =~ DATE_REGEX
      Date.strptime(earliest_departure.strip, "%m/%d/%Y")
    else
      nil
    end
  end

  def initialize(account)
    @account = account
    @no_of_passengers = 1
    @type = "return"
    @will_accept_economy         = false
    @will_accept_premium_economy = false
    @will_accept_business_class  = false
    @will_accept_first_class     = false
    @earliest_departure = Date.today.strftime("%m/%d/%Y")
  end

  def self.name
    "TravelPlan"
  end

  def self.types
    ::TravelPlan.types.slice("single", "return")
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
        validates :further_information, length: { maximum: 500 }
      end

      validate :earliest_departure_is_in_the_future
    end

    private

    def earliest_departure_is_in_the_future
      date = earliest_departure_as_date
      if date && date < Date.today
        errors.add(:earliest_departure, "can't be in the past")
      end
    end
  end

end

