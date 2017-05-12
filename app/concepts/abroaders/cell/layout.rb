module Abroaders
  module Cell
    # Placeholder class until application.html.erb and basic.html.erb are
    # fully extracted to cells
    class Layout < Abroaders::Cell::Base
      option :title

      # once the view is fully converted to a cell, everything below this
      # line should be made private:

      def head
        cell(Head, nil, title: title)
      end

      def navbar
        cell(Navbar, current_user)
      end

      def noscript
        cell(Noscript)
      end

      def sidebar
        @sidebar ||= cell(Sidebar, current_user)
      end

      def sidebar?
        sidebar.show?
      end

      private

      def current_user
        current_account || current_admin
      end

      class Head < Abroaders::Cell::Base
        include ActionView::Helpers::CsrfHelper
        include ::Cell::Helper::AssetHelper

        BASE_TITLE = "Abroaders".freeze

        option :title

        private

        def full_title
          title.empty? ? BASE_TITLE : "#{title.strip} | #{BASE_TITLE}"
        end
      end
    end
  end
end
