class RecommendationRequest # < RecommendationRequest.superclass
  module Cell
    # @!method self.call(result, options = {})
    #   @option result [Collection<Person>] people with an unconfirmed
    #     rec request. Will raise an error if they don't have one.
    class Confirm < Abroaders::Cell::Base
      extend Abroaders::Cell::Result

      skill :people

      def initialize(result, options = {})
        raise unless result['people'].all?(&:unconfirmed_recommendation_request)
        super
      end

      def show
        "#{main_header}
        #{cell(ConfirmPersonalSpending, account)}
        #{cell(ConfirmPerson, collection: people)}"
      end

      private

      def account
        people.first.account
      end

      def main_header
        who = "You're requesting new card recommendations"
        if account.couples?
          names = escape(people.map(&:first_name).join(' and '))
          who << " for #{'both ' if people.size > 2}#{names}"
        end
        who << '.'

        <<-HTML
          <div class="alert alert-info">
            #{who}

            Please check that all your data is up-to-date and click 'Confirm'
            below.
          </div>
        HTML
      end

      # @!method self.call(person, options = {})
      #   @param person [Person] person with an unconfirmed rec request. Will
      #     raise an error if they don't have one.
      class ConfirmPerson < Abroaders::Cell::Base
        include Abroaders::Cell::Hpanel
        include Escaped

        def initialize(person, options = {})
          if person.unconfirmed_recommendation_request.nil?
            raise 'person must have an unconfirmed rec request'
          end
          super(EligiblePerson.build(person), options)
        end

        property :id
        property :card_accounts
        property :credit_score
        property :first_name
        property :has_partner?

        private

        def credit_score_form(&block)
          form_tag(
            confirm_person_spending_info_path(id),
            class: 'confirm_person_credit_score_form',
            data: { remote: true },
            method: :patch,
            style: 'display:none;',
            &block
          )
        end

        def credit_score_field
          number_field(
            :spending_info,
            :credit_score,
            max: SpendingInfo::MAXIMUM_CREDIT_SCORE,
            min: SpendingInfo::MINIMUM_CREDIT_SCORE,
            value: credit_score,
          )
        end

        def your
          has_partner? ? "#{first_name}'s" : 'Your'
        end
      end

      # @!method self.call(account, options = {})
      class ConfirmPersonalSpending < Abroaders::Cell::Base
        property :couples?
        property :monthly_spending_usd
        property :people

        private

        def field
          number_field(
            :spending_info,
            :monthly_spending_usd,
            min: 0,
            value: monthly_spending_usd,
          )
        end

        def form(&block)
          form_tag(
            # Either person's ID will work here:
            confirm_person_spending_info_path(people.first.id),
            class: 'confirm_personal_spending_form',
            data: { remote: true },
            method: :patch,
            style: 'display:none;',
            &block
          )
        end

        def is_this_your_current_spending
          usd = number_to_currency(monthly_spending_usd)
          "Is your personal monthly spending still <b>#{usd}</b>?"
        end

        def spending_who
          text = if couples?
                   names = escape(people.map(&:first_name).join(' and '))
                   "the combined average monthly spending for both #{names} "
                 else
                   'your average monthly spending '
                 end
          text << 'that can be charged to a credit card account.'
        end

        def spending_explanation
          "This should be #{spending_who}"
        end

        def spending_input_explanation
          "Please tell us #{spending_who}"
        end

        def what_you_should_exclude
          'You should exclude rent, mortage, and car payments unless you are '\
          'certain you can use a credit card as the payment method.'
        end
      end
    end
  end
end
