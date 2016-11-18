class Bank::Cell < Trailblazer::Cell
  class FilterPanel < Trailblazer::Cell
    include Recommendation::FilterPanel
    alias banks model

    property :name

    private

    def title
      'Bank'
    end

    def check_box_tags
      banks.map do |bank|
        html_id = "#{CHECK_BOX_HTML_CLASS}_#{bank.id}"
        label_tag html_id do
          check_box_tag(
            html_id,
            nil,
            true,
            class: CHECK_BOX_HTML_CLASS,
            data: { key: :bank, value: bank.id },
          ) << raw("&nbsp;&nbsp#{bank.name}")
        end
      end.join
    end

    CHECK_BOX_HTML_CLASS = 'card_bank_filter'.freeze
  end
end
