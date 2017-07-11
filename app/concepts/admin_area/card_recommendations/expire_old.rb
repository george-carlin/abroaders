module AdminArea
  module CardRecommendations
    # Mark as 'expired' all recommendations which:
    #
    # a) were recommended to the user more than [setting] days ago
    # b) have not been interacted with by the user (clicked, declined, or
    #    applied for)
    # c) are not already expired
    #
    # Users won't see expired recs anymore on their /cards page.
    #
    # This operation will be run from a script that runs daily in production.
    class ExpireOld < Trailblazer::Operation
      self['expire_after_no_of_days'] = 180

      step :expire_old_recs!

      private

      def expire_old_recs!(opts)
        Card.recommended.unclicked.unapplied.unexpired.undeclined.where(
          "recommended_at < '#{opts['expire_after_no_of_days'].days.ago.utc.to_s(:db)}'",
        ).update_all(expired_at: Time.zone.now)
      end
    end
  end
end
