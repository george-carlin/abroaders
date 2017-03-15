class TravelPlan < TravelPlan.superclass
  module Cell
    # Takes a TravelPlan, and returns a short string representing the COS for
    # that plan. If no classes have been marked as acceptable, returns "None
    # Given". If at least one class has been marked as acceptable, returns the
    # initials of the acceptable classes. E.g. if all four classes are
    # acceptable, returns "E PE B 1st". If only business and 1st class are
    # acceptable, returns "B 1st".
    class AcceptableClasses < Abroaders::Cell::Base
      def show
        abbreviations = []
        abbreviations << 'E'   if model.accepts_economy?
        abbreviations << 'PE'  if model.accepts_premium_economy?
        abbreviations << 'B'   if model.accepts_business_class?
        abbreviations << '1st' if model.accepts_first_class?

        if abbreviations.any?
          abbreviations.join(' ')
        else
          'None given'
        end
      end
    end
  end
end
