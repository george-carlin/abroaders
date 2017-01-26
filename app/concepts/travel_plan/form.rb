class TravelPlan < ApplicationRecord
  class Form < Reform::Form
    feature Reform::Form::Coercion

    AIRPORT_REGEX = /\(([A-Z]{3})\)\s*\z/
    # An AirportString is a string in the format "Airport Name (XXX)" where XXX
    # is an IATA code. E.g. "London Heathrow (LHR)". On the front-end,
    # typeahead.js will fill the HTML <input> with a string in this format
    # which then gets submitted to the server. It's our job at the back-end to
    # make sense of the string and figure out which airport they mean.
    #
    # Previously we were trying to do more on the frontend by having the JS
    # also update a hidden field with the airport's ID, and submitting that ID
    # to the server directly. Turns out that this approach didn't work in some
    # edge cases, so the current 'least bad' solution is to submit the full
    # string and let the server figure out the airport ID for itself.
    AirportString = Types::Strict::String.constrained(format: AIRPORT_REGEX)

    property :from, type: AirportString, virtual: true
    property :to,   type: AirportString, virtual: true
    # It's not possible to submit an invalid type through the normal form, so let it blow up:
    property :type, type: Types::Strict::String.enum('single', 'return'), default: "return"
    property :no_of_passengers,        type: Types::Form::Int, default: 1
    property :accepts_economy,         type: Types::Form::Bool, default: false
    property :accepts_premium_economy, type: Types::Form::Bool, default: false
    property :accepts_business_class,  type: Types::Form::Bool, default: false
    property :accepts_first_class,     type: Types::Form::Bool, default: false
    # Call these '*_date' rather than '*_on' (which are the names of the
    # underlying DB column) so that we get friendly error messages
    property :depart_on, type: Types::Form::AmericanDate
    property :return_on, type: Types::Form::AmericanDate
    property :further_information, type: Types::StrippedString.optional

    def sync
      super
      model.flights.build(
        from: Airport.find_by_code!(AIRPORT_REGEX.match(from)[1]),
        to:   Airport.find_by_code!(AIRPORT_REGEX.match(to)[1]),
      )
      model
    end

    def self.model_name
      TravelPlan.model_name
    end

    def self.types
      ::TravelPlan.types.slice("single", "return")
    end

    def depart_on_str
      if depart_on.is_a?(Date)
        depart_on.strftime(Types::Form::AmericanDate.meta(:format))
      elsif depart_on.nil?
        ""
      else
        depart_on
      end
    end

    def return_on_str
      if return_on.is_a?(Date)
        return_on.strftime(Types::Form::AmericanDate.meta(:format))
      elsif return_on.nil?
        ""
      else
        return_on
      end
    end

    def owner_name(suffix = false)
      suffix = suffix ? "r" : ""
      "you#{suffix}"
    end

    validation do
      # TODO convert to use dry-validation
      validates :depart_on, presence: true
      validates :from, presence: true
      validates(
        :no_of_passengers,
        numericality: {
          greater_than_or_equal_to: 1,
          less_than_or_equal_to: TravelPlan::MAX_PASSENGERS,
          # avoid a duplicative error message when blank:
          allow_blank: true,
        },
        presence: true,
      )
      validates :to, presence: true

      validates :return_on, presence: { if: :return? }, absence: { if: :single? }
      validates :further_information, length: { maximum: 500 }
      validate :depart_on_is_in_the_future
      validate :return_on_is_in_the_future
      validate :return_is_later_than_or_equal_to_departure
      # Not bothering to validate that 'from' or 'to' a) follow the expected
      # format or b) correspond to real airports in our DB. In both cases they
      # shouldn't be able to submit data like this unless they've been
      # tinkering with the HTML form, in which case we can just let it blow up
      # and don'to bother displaying pretty validation errors to them.
    end

    private

    def depart_on_is_in_the_future
      if depart_on.is_a?(Date)
        if depart_on < Time.zone.today
          errors.add(:depart_on, "can't be in the past")
        end
      end
    end

    def return_on_is_in_the_future
      if return_on.is_a?(Date)
        if return_on < Time.zone.today
          errors.add(:return_on, "can't be in the past")
        end
      end
    end

    def return_is_later_than_or_equal_to_departure
      if return_on.is_a?(Date)
        if depart_on.is_a?(Date) && return_on < depart_on
          errors.add(:return_on, "can't be earlier than departure date")
        end
      end
    end

    def travel_plan_attributes
      {
        acceptable_classes:   acceptable_classes,
        depart_on:            depart_on,
        further_information:  (further_information.strip if further_information.present?),
        no_of_passengers:     no_of_passengers,
        return_on:            return_on,
        type:                 type,
      }
    end

    def acceptable_classes
      [
        (:economy         if accepts_economy?),
        (:premium_economy if accepts_premium_economy?),
        (:business_class  if accepts_business_class?),
        (:first_class     if accepts_first_class?),
      ].compact
    end

    def single?
      type == "single"
    end

    def return?
      type == "return"
    end
  end
end
