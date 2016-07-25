module CardAccount::Expiration
  EXPIRE_AFTER_NO_OF_DAYS = 15

  # Mark as 'expired' all recommendations which:
  #
  # a) were recommended to the user more than 15 days ago
  # b) have not been interacted with by the user (clicked, declined, or
  #    applied for)
  # c) are not already expired
  #
  # Users won't see expired recs anymore on their /cards page.
  #
  # This method will be called from a script that runs daily in production.
  def expire_old_recommendations!
    cutoff_point = EXPIRE_AFTER_NO_OF_DAYS.days.ago

    visible.unclicked.unapplied.where("recommended_at < '#{cutoff_point.utc.to_s(:db)}'").\
        update_all(expired_at: Time.now)
  end

end
