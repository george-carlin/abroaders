module AdminArea
  module CardRecommendations
    module Cell
      # @!method self.call(rec, options = {})
      class Edit < Abroaders::Cell::Base
        property :person
        option :form

        private

        def date_inputs(f)
          %w[recommended_at applied_on denied_at nudged_at called_at
             redenied_at declined_at].map do |attr|
            cell(DateFormGroup, attribute_name: attr, form_builder: f)
          end
        end

        def errors
          cell(Abroaders::Cell::ValidationErrorsAlert::ActiveModel, form)
        end

        def link_back_to_person
          link_to "Back to #{escape(person.first_name)}", admin_person_path(person)
        end

        class DateFormGroup < Abroaders::Cell::Base
          option :form_builder
          option :attribute_name

          alias f form_builder

          # allow the options to be passed in as the first (and only) arg:
          def initialize(options = {}, other_options = {})
            super(nil, other_options.merge(options))
          end

          private

          def check_box
            check_box_tag(
              "toggle_#{attribute_name}",
              true,
              date_present?,
              class: 'card_rec_toggle_date',
              data: { target: "card_recommendation_#{attribute_name}" },
            )
          end

          def date_select
            f.date_select(
              attribute_name,
              {
                end_year:   Date.today.year,
                order:      [:month, :day, :year],
                start_year: Date.today.year - 10,
                use_short_month: true,
                disabled: !date_present?,
              },
              style: 'width: 32%; display: inline-block;',
            )
          end

          def label
            text = attribute_name.to_s.humanize.split[0] << ':'
            f.label(attribute_name, text)
          end

          def date_present?
            !f.object.send(attribute_name).nil?
          end
        end
      end
    end
  end
end
