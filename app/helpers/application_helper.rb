module ApplicationHelper
  include BootstrapOverrides::Overrides

  def full_title(page_title)
    base_title = "Abroaders"
    page_title.empty? ? base_title : "#{page_title.strip} | #{base_title}"
  end

end
