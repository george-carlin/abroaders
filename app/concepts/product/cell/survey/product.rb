class Product::Cell::Survey < Trailblazer::Cell
  class Product < ::Product::Cell
    include ActionView::Helpers::FormOptionsHelper
    include BootstrapOverrides::Overrides

    private

    def opened_check_box
      cell(Opened::CheckBox, model)
    end

    def opened_label
      cell(Opened::Label, model)
    end

    def html_id
      dom_id(model)
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

    class Opened < ::Product::Cell
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
            full_name,
          )
        end
      end
    end
  end
end
