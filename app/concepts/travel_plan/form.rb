class TravelPlan < ApplicationRecord
  class Form < Reform::Form
    feature Reform::Form::Coercion

    # 'from' and 'to' are both strings in the format "Airport Name (XXX)" where
    # XXX is an IATA code. E.g. "London Heathrow (LHR)". On the front-end,
    # typeahead.js will fill the HTML <input> with a string in this format
    # which then gets submitted to the server. It's the back-end's job to make
    # sense of the string and figure out which airport they mean.
    #
    # Note that the user can still submit a blank string or an invalid one just
    # by typing into the text field without selecting any of the autocomplete
    # suggestions, so this error needs to be handled gracefully.
    #
    # Previously we were trying to do more on the frontend by having the JS
    # also update a hidden field with the airport's ID, and submitting that ID
    # to the server directly. Turns out that this approach didn't work in some
    # edge cases, so the current 'least bad' solution is to submit the full
    # string and let the server figure out the airport ID for itself.
    AIRPORT_REGEX = /\(([A-Z]{3})\)\s*\z/
    # The underlying TravelPlan model stores 'from' and 'to' in a nested
    # Flight (although for legacy reasons every TP only has one flight). The
    # simplest solution I could find was to make these virtual attributes
    # and build the flight 'manually' when syncing. (See also #prepopulate!)
    property :from, type: Types::Strict::String, virtual: true
    property :to,   type: Types::Strict::String, virtual: true

    # The input for dates will be set with the bootstrap-datepicker.js plugin,
    # and will be received as a string in the format m/d/y.
    property :depart_on, type: Types::Form::AmericanDate
    property :return_on, type: Types::Form::AmericanDate

    # It's not possible to submit an invalid type through the normal form, so let it blow up:
    property :type, type: Types::Strict::String.enum('single', 'return')
    property :no_of_passengers,        type: Types::Form::Int, default: 1
    property :accepts_economy,         type: Types::Form::Bool, default: false
    property :accepts_premium_economy, type: Types::Form::Bool, default: false
    property :accepts_business_class,  type: Types::Form::Bool, default: false
    property :accepts_first_class,     type: Types::Form::Bool, default: false
    property :further_information, type: Types::StrippedString.optional

    # Override the default 'sync' method so that the Flights get built
    # correctly.
    def sync
      super
      f = Airport.find_by_code!(AIRPORT_REGEX.match(from)[1])
      t = Airport.find_by_code!(AIRPORT_REGEX.match(to)[1])
      if model.persisted?
        model.flights[0].attributes = { to: t, from: f }
      else
        model.flights.build(to: t, from: f)
      end
      model
    end

    # Prepopulate should be called before editing.
    def prepopulate!(_opts = {})
      if (flight = model.flights[0])
        self.from = flight.from&.full_name
        self.to   = flight.to&.full_name
      end
    end

    def owner_name(suffix = false)
      suffix = suffix ? "r" : ""
      "you#{suffix}"
    end

    validation do
      # TODO convert to use dry-validation
      validates :depart_on, presence: true
      validates :from, presence: true, format: AIRPORT_REGEX
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
      validates :to, presence: true, format: AIRPORT_REGEX

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
      if depart_on.is_a?(Date) && depart_on < Time.zone.today
        errors.add(:depart_on, "can't be in the past")
      end
    end

    def return_on_is_in_the_future
      if return_on.is_a?(Date) && return_on < Time.zone.today
        errors.add(:return_on, "can't be in the past")
      end
    end

    def return_is_later_than_or_equal_to_departure
      if return_on.is_a?(Date) && depart_on.is_a?(Date) && return_on < depart_on
        errors.add(:return_on, "can't be earlier than departure date")
      end
    end

    def return?
      type == 'return'
    end

    def single?
      type == 'single'
    end
  end
end
