module Abroaders
  module Cell
    # Placeholder class until we convert the whole layout to a cell
    class Layout < Abroaders::Cell::Base
      class Head < Abroaders::Cell::Base
        include ActionView::Helpers::CsrfHelper
        include ::Cell::Helper::AssetHelper

        BASE_TITLE = "Abroaders".freeze

        def head
          cell(Head)
        end

        def sidebar
          cell(Sidebar, model) if sidebar?
        end

        option :title

        def stylesheet_link_tag(*args)
          super
        end

        private

        def full_title
          title.empty? ? BASE_TITLE : "#{title.strip} | #{BASE_TITLE}"
        end
      end
    end
  end
end
