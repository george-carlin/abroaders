class SpendingInfo < SpendingInfo.superclass
  module Cell
    # @!method self.call(result, opts = {})
    #   @param result [Trailblazer::Operation::Result]
    #   @option result [Collection<People>] eligible_people
    #   @option result [Account] account
    #   @option result [Reform::Form] contract.default
    class Survey < Abroaders::Cell::Base
      extend Abroaders::Cell::Result
      include ::Cell::Builder

      skill :eligible_people
      skill :account

      builds do |result|
        case result['eligible_people'].size
        when 1 then SoloSurvey
        when 2 then CouplesSurvey
        else raise 'account must have 1 or 2 eligible people'
        end
      end

      # Always render survey.erb, even from within subclasses
      def show
        render view: 'survey'
      end

      def title
        'Spending Information'
      end

      private

      def business_spending_form_groups(form_builder)
        cols = "col-xs-12 #{'col-md-6' if eligible_people.size > 1}"
        eligible_people.map do |person|
          content_tag :div, class: cols do
            cell(
              BusinessSpendingFormGroup,
              person,
              form_builder: form_builder,
              use_name: use_name,
            )
          end
        end
      end

      def credit_score_form_groups(form_builder)
        cols = "col-xs-12 #{'col-md-6' if eligible_people.size > 1}"
        eligible_people.map do |person|
          content_tag :div, class: cols do
            cell(
              CreditScoreFormGroup,
              person,
              form_builder: form_builder,
              use_name: use_name,
            )
          end
        end
      end

      def form
        result['contract.default']
      end

      def monthly_spending_form_group(form_builder)
        cell(MonthlySpendingFormGroup, eligible_people, form_builder: form_builder)
      end

      def will_apply_for_loan_form_groups(form_builder)
        cols = "col-xs-12 #{'col-md-6' if eligible_people.size > 1}"
        eligible_people.map do |person|
          content_tag :div, class: cols do
            cell(
              WillApplyForLoanFormGroup,
              person,
              form_builder: form_builder,
              use_name: use_name,
            )
          end
        end
      end

      class BusinessSpendingFormGroup < Abroaders::Cell::Base
        include Escaped

        property :first_name
        property :type

        VALUES = {
          'with_ein' => 'Yes, with an EIN (Employer ID Number)',
          'without_ein' => 'Yes, without an EIN (Employer ID Number)',
          'no_business' => 'No, I don\'t own a business',
        }.freeze

        private

        def f
          options.fetch(:form_builder)
        end

        def has_business_radios
          VALUES.map do |value, label_text|
            content_tag :div, class: 'radio' do
              content_tag :label do
                f.radio_button(
                  "#{type}_has_business",
                  value,
                  class: "spending_info_#{type}_has_business",
                ) + label_text
              end
            end
          end
        end

        def header_text
          if options[:use_name]
            "Does <b>#{first_name}</b> have a business?"
          else
            'Do you have a business?'
          end
        end

        def spending_field
          f.number_field(
            "#{type}_business_spending_usd",
            min: '0',
            placeholder: 'Estimated monthly business spending',
          )
        end

        def spending_field_is_hidden?
          !%w[with_ein without_ein].include?(f.object["#{type}_has_business"])
        end
      end

      class CreditScoreFormGroup < Abroaders::Cell::Base
        include Escaped

        property :first_name
        property :type

        def show
          content_tag :div, class: 'form-group' do
            header << help_block << field
          end
        end

        TOOLTIP_TEXT = "We ask for your credit score to make sure we only "\
                       "recommend cards for which you’re likely to be approved. "\
                       "The strategies we recommend to maximize rewards should "\
                       "improve your credit over time. If you're not sure what "\
                       "your credit score is, please give us your best guess.".freeze

        private

        def field
          options.fetch(:form_builder).number_field "#{type}_credit_score"
        end

        def header
          content_tag :h3 do
            "#{header_text} <small>#{tooltip}</small>"
          end
        end

        def header_text
          if options[:use_name]
            "What is <b>#{first_name}'s</b> credit score?"
          else
            'What is your credit score?'
          end
        end

        def help_block
          content_tag(
            :p,
            'A credit score should be a number between 350 and 850.&nbsp;',
            class: 'help-block',
          )
        end

        def tooltip
          cell(
            Abroaders::Cell::SpanWithTooltip,
            text: 'More info',
            tooltip_text: TOOLTIP_TEXT,
          )
        end
      end

      class CouplesSurvey < self
        private

        def col_classes
          'col-md-12 col-xs-12'
        end

        def use_name
          true
        end
      end

      # @!method self.call(people, options = {})
      #   @param people [Collection<Person>]
      class MonthlySpendingFormGroup < Abroaders::Cell::Base
        private

        def field
          options.fetch(:form_builder).number_field(
            :monthly_spending,
            min: 0,
            placeholder: 'Estimated monthly spending',
          )
        end

        def help_text
          paragraphs = []
          if model.size > 1
            names = escape(model.map(&:first_name).join(' and '))

            paragraphs.push(
              "Please estimate the <b>combined</b> monthly spending "\
              "for #{names} that could be charged to a credit card account.",
            )
          else
            paragraphs.push(
              'What is your average monthly personal spending that could be '\
              'charged to a credit card account?',
            )
          end
          paragraphs.push(
            'You should exclude rent, mortage, and car payments unless you '\
            'are certain you can use a credit card as the payment method.',
          )
          paragraphs.map do |paragraph|
            content_tag :p, paragraph, class: 'help-block'
          end
        end
      end

      class SoloSurvey < self
        private

        def col_classes
          'col-md-6 col-md-offset-3 col-xs-12'
        end

        def use_name
          false
        end
      end

      class WillApplyForLoanFormGroup < Abroaders::Cell::Base
        include Escaped

        property :first_name
        property :type

        TOOLTIP_TEXT = "Your credit score is especially important right "\
                       "before you apply for a loan or mortgage. Although "\
                       "the strategies we recommend should have a positive "\
                       "effect on your credit over time, it is common to see "\
                       "a small drop in your credit score immediately after "\
                       "you apply for a new card. If you answer yes to this "\
                       "question, we may recommend you wait until after "\
                       "you’ve applied for the loan before opening new cards.".freeze

        VALUES = {
          'true'  => 'Yes',
          'false' => 'No',
        }.freeze

        private

        def header_text
          do_you = if options[:use_name]
                     "Does <b>#{first_name}</b>"
                   else
                     'Do you'
                   end
          "#{do_you} plan to apply for a loan of over $5,000 in the next 12 months?"
        end

        def f
          options.fetch(:form_builder)
        end

        def radios
          VALUES.map do |value, label|
            content_tag :div, class: 'radio' do
              content_tag :label do
                f.radio_button("#{type}_will_apply_for_loan", value) + label
              end
            end
          end
        end

        def tooltip
          cell(
            Abroaders::Cell::SpanWithTooltip,
            text: 'More info',
            tooltip_text: TOOLTIP_TEXT,
          )
        end
      end
    end
  end
end
