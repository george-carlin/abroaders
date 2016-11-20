module CardAccount::Expiration
  extend ActiveSupport::Concern

  EXPIRE_AFTER_NO_OF_DAYS = 15

  included do
    # returns cards which are set to expire unless the user acts in time
    scope :expirable, -> do
      recommendations.unclicked.unapplied.unexpired.undeclined.unpulled
    end
  end

  module ClassMethods
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
    #
    # @return [Fixnum] the number of recs that were expired
    def expire_old_recommendations!
      expirable.where(
        "recommended_at < '#{EXPIRE_AFTER_NO_OF_DAYS.days.ago.utc.to_s(:db)}'",
      ).update_all(expired_at: Time.now)
    end
  end
end
