module CurrentUserHelper

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
