class Abroaders::Cell < Trailblazer::Cell
  class Sidebar < Trailblazer::Cell
    include ::Cell::Builder

    builds do |model|
      case model
      when Account then self
      when Admin   then AdminSidebar
      end
    end

    def container(&block)
      content_tag :aside, id: :menu do
        content_tag :div, id: :navigation do
          content_tag :ul, id: 'side-menu', class: :nav, &block
        end
      end
    end

    def link(text, href, controller_class = nil)
      active = if controller_class
                 controller.is_a?(controller_class)
               else
                 request.path == href
               end
      content_tag :li, class: ('active' if active) do
        link_to href do
          content_tag :span, text, class: 'nav-label'
        end
      end
    end

    def nested_links(title, links, controller_class = nil)
      cell(NestedLinks, nil, title: title, links: links, controller_class: controller_class)
    end

    class AdminSidebar < self
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
