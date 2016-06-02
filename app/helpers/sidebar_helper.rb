module SidebarHelper

  def sidebar_link_to(text, href)
    content_tag :li, class: ("active" if request.path == href) do
      link_to href do
        content_tag :span, text, class: "nav-label"
      end
    end
  end

  def sidebar?
    # Urgh... this probably isn't the best way to handle sidebar-less layouts
    # but it'll do for now.
    !content_for?(:no_sidebar)
  end

end
