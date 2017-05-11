module Onboarding
  module Cell
    # @!method self.call(account, options = {})
    #   @param account [Account] currently logged-in account
    class ProgressBar < Abroaders::Cell::Base
      property :onboarding_state

      def show
        return '' if model.nil? || model.onboarded?
        render
      end

      def percentage_complete
        case onboarding_state.to_sym
        when :home_airports, :travel_plan, :regions_of_interest
          15
        when :account_type, :eligibility
          30
        when :owner_cards
          40
        when :owner_balances
          50
        when :companion_cards
          60
        when :companion_balances
          70
        when :spending
          75
        when :readiness
          90
        when :phone_number
          100
        when :complete
          raise "unknown progress # for state '#{onboarding_state}'"
        end
      end

      def phase_number
        case onboarding_state.to_sym
        when :home_airports, :travel_plan, :regions_of_interest
          1
        when :account_type, :eligibility
          2
        when :owner_cards, :owner_balances, :companion_cards, :companion_balances
          3
        when :spending
          4
        when :readiness
          5
        when :phone_number
          6
        else
          raise "unknown phase # for state '#{onboarding_state}'"
        end
      end

      def phase_name
        [
          nil, # so that we can use 1-indexing rather than 0-indexing
          'Travel Plans',
          'Account',
          'Cards and Points',
          'Spending',
          'Almost There',
          'Complete',
        ][phase_number]
      end
    end
  end
end
