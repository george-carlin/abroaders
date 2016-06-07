module SidebarHelper

  def sidebar_link_to(text, href, controller_class=nil)
    active  = if controller_class
                controller.is_a?(controller_class)
              else
                request.path == href
              end
    content_tag :li, class: ("active" if active) do
      link_to href do
        content_tag :span, text, class: "nav-label"
      end
    end
  end

  def sidebar_nested_links(title, nested_links, controller_class=nil)
    active  = if controller_class
                controller.is_a?(controller_class)
              else
                nested_links.any? { |_, href| href == request.path }
              end
    content_tag(
      :li,
      class: ("active" if active),
      "aria-expanded": active,
    ) do
      li_content = link_to "#", "aria-expanded": active do
        raw(%[<span class="nav-label">#{title}</span><span class="fa arrow"></span>])
      end

      li_content << content_tag(
        :ul,
        class: "nav nav-second-level",
        "aria-expanded": active
      ) do
        raw(nested_links.map { |text, href| sidebar_nested_link_to(text, href) }.join)
      end
    end
  end

  def sidebar?
    # Urgh... this probably isn't the best way to handle sidebar-less layouts
    # but it'll do for now.
    !content_for?(:no_sidebar)
  end

  private

  def sidebar_nested_link_to(text, href)
    content_tag :li, class: ("active" if request.path == href) do
      link_to(text, href)
    end
  end

end
