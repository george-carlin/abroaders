class RecommendationNote < RecommendationNote.superclass
  module Cell
    # takes a RecommendationNote and returns its content, formatted as
    # paragraphs with <a> tags added to anything that looks like a link
    class FormattedContent < Trailblazer::Cell
      include Escaped
      property :content

      def show
        auto_link(simple_format(content))
      end
    end
  end
end
