module ApplicationHelper
  include BootstrapOverrides::Overrides

  def full_title(page_title)
    base_title = "Abroaders"
    page_title.empty? ? base_title : "#{page_title.strip} | #{base_title}"
  end

  def current_main_passenger
    current_account.try(:main_passenger)
  end

  def current_companion
    current_account.try(:companion)
  end

  def has_companion?
    current_account.try(:has_companion?)
  end

end
