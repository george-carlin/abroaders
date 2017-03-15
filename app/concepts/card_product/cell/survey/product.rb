# TODO really this belongs under the 'cards' concept, not under 'card
# products'
class CardProduct < CardProduct.superclass
  module Cell
    module Survey
      # An individual product on the cards survey. Displays the product's image
      # and has inputs to set the opened and closed dates.
      class Product < Abroaders::Cell::Base
        property :id

        private

        def annual_fee
          cell(AnnualFee, model)
        end

        def image(size = "180x114")
          cell(Image, model, size: size)
        end

        def html_id
          dom_id(model)
        end

        def opened_check_box
          cell(Opened::CheckBox, model)
        end

        def opened_label
          cell(Opened::Label, model)
        end

        # TODO could these be replaced with Rails's 'date_select'? (the date <selects>
        # don't have the same 'name' that a standard Rails form input would have,
        # so perhaps not.)
        def options_for_month_select
          options = Date::MONTHNAMES.compact.map.with_index { |m, i| [m.first(3), i + 1] }
          options_for_select options
        end

        def options_for_year_select
          options = (Date.today.year - 15)..Date.today.year
          options_for_select options, Date.today.year
        end

        # Superclass for the 'opened' attribute's checkbox and label, each of
        # which are their own subclass. Don't instantiate directly. Subclasses
        # take a CardProduct as their model.
        class Opened < Abroaders::Cell::Base
          include BootstrapOverrides

          property :id

          private

          def html_id
            "cards_survey_#{id}_card_opened"
          end

          class CheckBox < self
            def show
              check_box_tag(
                "cards_survey[cards][][opened]",
                true,  # value
                false, # checked
                id:    html_id,
                class: 'cards_survey_card_opened cards_survey_opened input-lg',
              )
            end
          end

          class Label < self
            def show
              label_tag(
                "cards_survey_#{id}_card_opened",
                CardProduct::Cell::FullName.(model).(),
              )
            end
          end
        end
      end
    end
  end
end
