module Abroaders
  module Cell
    class Sidebar < Abroaders::Cell::Base
      include ::Cell::Builder

      builds do |model|
        case model
        when Account then AccountSidebar
        when Admin   then AdminSidebar
        end
      end

      private

      def container(&block)
        content_tag :aside, id: :menu do
          content_tag :div, id: :navigation do
            content_tag :ul, id: 'side-menu', class: :nav, &block
          end
        end
      end

      def link(text, href, icon_name = nil, controller_class = nil)
        active = if controller_class
                   controller.is_a?(controller_class)
                 else
                   request.path == href
                 end
        content_tag :li, class: ('active' if active) do
          link_to href do
            text = icon_name.nil? ? text : "#{fa_icon(icon_name)} #{text}"

            content_tag :span, text, class: 'nav-label'
          end
        end
      end

      def nested_links(title, links, controller_class = nil)
        cell(NestedLinks, nil, title: title, links: links, controller_class: controller_class)
      end

      class AccountSidebar < self
        def link_to_financials
          return '' unless model.people.any?(&:eligible)
          link 'My Financials', spending_info_path, 'dollar', SpendingInfosController
        end
      end

      class AdminSidebar < self
        def link(text, href, controller_class = nil)
          super(text, href, nil, controller_class)
        end
      end

      class NestedLinks < self
        private

        def active
          if options[:controller_class]
            controller.is_a?(options[:controller_class])
          else
            options[:links].any? { |_, href| href == request.path }
          end
        end

        def links
          options[:links].map { |text, href| link(text, href) }.join
        end
      end
    end
  end
end
