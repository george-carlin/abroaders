class RecommendationRequest # < RecommendationRequest.superclass
  module Cell
    class New < Abroaders::Cell::Base
      # @param people [Collection<Person>] people who want to request a rec.
      #   An error will be raised if any of them can't request a rec
      def initialize(people, options = {})
        raise unless people.all? { |p| Policy.new(p).create? }
        super
      end

      private

      def account
        model.first.account
      end

      def cancel_btn
        link_to 'Cancel', root_path, class: 'btn btn-default btn-lg'
      end

      def main_header
        who = "You're requesting new card recommendations"
        if account.couples?
          names = escape(model.map(&:first_name).join(' and '))
          who << " for #{'both ' if model.size > 2}#{names}"
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

      def submit_btn
        button_to(
          'Submit Request',
          recommendation_requests_path(person_type: params[:person_type]),
          class: 'btn btn-primary btn-lg',
          form: { style: 'display: inline-block;' },
        )
      end

      # @!method self.call(person, options = {})
      #   @param person [Person] person with an unresolved rec request. Will
      #     raise an error if they don't have one.
      class ConfirmPerson < Abroaders::Cell::Base
        include Abroaders::Cell::Hpanel
        include Escaped

        def initialize(person, options = {})
          if person.unresolved_recommendation_request?
            raise 'person must have an unresolved rec request'
          end
          super(EligiblePerson.build(person), options)
        end

        property :id
        property :business_spending_usd
        property :business_has_ein?
        property :business?
        property :card_accounts
        property :credit_score
        property :first_name
        property :partner?

        private

        def business_current
          if business?
            result = "You told us that #{you_have} a business "
            result << "<b>with #{business_has_ein? ? 'an' : ' no'} EIN</b> (Employer ID Number) "
            result << "and that the business spends, on average, "
            result << "<b>#{number_to_currency(business_spending_usd)}</b> a month."
          else
            "You told us that #{you_dont_have} a business."
          end
        end

        def business_spending_form(&block)
          form_tag(
            confirm_person_spending_info_path(id),
            class: 'confirm_person_business_spending_form',
            data: { remote: true },
            method: :patch,
            style: 'display:none;',
            &block
          )
        end

        def business_spending_form_fields
          cell(BusinessSpendingFormFields, model)
        end

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
            max: CreditScore.max,
            min: CreditScore.min,
            value: credit_score,
          )
        end

        def do_you_have
          partner? ? "Does #{first_name} have" : 'Do you have'
        end

        def you_dont_have
          partner? ? "#{first_name} doesn't have" : "you don't have"
        end

        def you_have
          partner? ? "#{first_name} has" : 'you have'
        end

        def your
          partner? ? "#{first_name}'s" : 'your'
        end
      end

      # @!method self.call(eligible_person, options = {})
      class BusinessSpendingFormFields < Abroaders::Cell::Base
        include Escaped

        property :business?
        property :business_spending_usd
        property :business_type

        VALUES = {
          'with_ein' => 'Yes, with an EIN (Employer ID Number)',
          'without_ein' => 'Yes, without an EIN (Employer ID Number)',
          'no_business' => 'No',
        }.freeze

        private

        def radio_buttons
          VALUES.map do |value, label_text|
            content_tag :div, class: 'radio' do
              content_tag :label do
                radio_button(
                  :spending_info,
                  :has_business,
                  value,
                  checked: business_type == value,
                  class: 'confirm_business_spending_radio',
                ) + label_text
              end
            end
          end
        end

        def spending_field
          number_field(
            :spending_info,
            :business_spending_usd,
            min: 0,
            placeholder: 'Estimated monthly business spending',
            value: (business? ? business_spending_usd : 0),
          )
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
            submit_path,
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

        def submit_path
          # We can use confirm_person_spending_info_path for either person, just as
          # long as the person we use has a spending info. On a couples account
          # that might only be one person.
          person_with_spending = people.detect { |p| p.spending_info.present? }
          # this should never happen, but be defensive anyway:
          raise if person_with_spending.nil?
          confirm_person_spending_info_path(person_with_spending)
        end

        def what_you_should_exclude
          'You should exclude rent, mortage, and car payments unless you are '\
          'certain you can use a credit card as the payment method.'
        end
      end
    end
  end
end
