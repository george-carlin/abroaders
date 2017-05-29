require 'rinku'

class RecommendationNote < RecommendationNote.superclass
  module Cell
    # takes a RecommendationNote and returns its content, formatted as
    # paragraphs with <a> tags added to anything that looks like a link
    class FormattedContent < Abroaders::Cell::Base
      include Escaped
      property :content

      def show
        Rinku.auto_link(simple_format(content))
      end
    end
  end
end
