module SidebarHelper

  def sidebar_link_to(text, href)
    content_tag :li, class: ("active" if request.path == href) do
      link_to href do
        content_tag :span, text, class: "nav-label"
      end
    end
  end

end
