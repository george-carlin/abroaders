module Abroaders
  module Cell
    # The layout. Pass the return value of 'yield' as the model.
    #
    # @!method self.call(html, options = {})
    #   @param html [String] a string of HTML
    #   @option option [Boolean] basic (false) when true, the sidebar and
    #     the '#wrapper' div won't be included in the rendered layout.
    #   @option options [ActionDispatch::Flash] flash
    #   @option options [String] title the page title
    class Layout < Abroaders::Cell::Base
      option :basic, default: false
      option :flash
      option :title

      private

      alias basic? basic

      def body_classes
        result = []
        result << 'blank' unless sidebar?
        result.push('fixed-navbar', 'fixed-sidebar') unless basic?
        result.join(' ')
      end

      def flash_alerts
        cell(FlashAlerts, flash)
      end

      def footer
        cell(Footer)
      end

      def head
        cell(Head, nil, title: title)
      end

      def navbar
        cell(
          Navbar,
          nil,
          current_account: current_account,
          current_admin: current_admin,
          sidebar?: sidebar?,
        )
      end

      def noscript
        cell(Noscript)
      end

      def progress_bar
        return '' if basic?
        cell(Onboarding::Cell::ProgressBar, current_account)
      end

      def rec_alert
        return '' if basic?
        cell(Abroaders::Cell::RecommendationAlert, current_account)
      end

      def sidebar
        @sidebar ||= cell(
          Sidebar,
          nil,
          current_account: current_account,
          current_admin: current_admin,
        )
      end

      def sidebar?
        !basic? && sidebar.show?
      end

      def third_party_scripts
        cell(ThirdPartyScripts)
      end

      def wrapper(&block)
        return yield if basic?
        content_tag(
          :div,
          id: 'wrapper',
          class: "wrapper #{'wrapper-with-sidebar' if sidebar?}",
        ) do
          content_tag :div, class: 'content', &block
        end
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
