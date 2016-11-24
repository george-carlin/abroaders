class Business::Cell < Trailblazer::Cell
  # Pass `nil` if there is no business. Else pass an object with the properties
  # declared below.
  class TableRow < Trailblazer::Cell
    property :spending_usd # int
    property :ein          # bool

    def show
      content_tag :tr do
        %[
          <td>Business spending:</td>
          <td>#{value}</td>
        ]
      end
    end

    include ActionView::Helpers::NumberHelper

    private

    def value
      return 'No business' unless model

      ein_span = content_tag(:span, class: "has-ein") do
        "(#{ein ? 'Has EIN' : 'Does not have EIN'})"
      end

      content_tag :span, class: "spending-info-business-spending" do
        number_to_currency(spending_usd) + ein_span
      end
    end
  end
end
