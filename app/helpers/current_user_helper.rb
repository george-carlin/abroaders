module CurrentUserHelper

  # TODO doesn't look like this method or the next one are actually being used:
  def current_owner
    current_account.try(:owner)
  end

  def current_companion
    current_account.try(:companion)
  end

  def has_companion?
    current_account.try(:has_companion?)
  end

end
