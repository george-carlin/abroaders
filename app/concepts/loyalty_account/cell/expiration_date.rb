class LoyaltyAccount < LoyaltyAccount.superclass
  module Cell
    # Returns a <span> with information about when the loyalty account expires.
    # If the loyalty account has no expiry date, then the text will say
    # 'Unknown'. If there's no expiry date, or the expiry date is in the past
    # or the very near future, then the <span> will also contain a warning
    # icon.
    #
    # @!method self.call(loyalty_account, options = {})
    #   @param loyalty_account [LoyaltyAccount]
    class ExpirationDate < ::Abroaders::Cell::Base
      property :expiration_date

      def show
        "<span class='loyalty_account_expiration_date'>#{icon}#{text}</span>"
      end

      private

      # If you look in the AwardWallet web interface, some accounts' expiration
      # date is 'Unknown' while others say 'will not expire'. However, it all
      # looks the same in the API data, so we're just marking everything as
      # 'unknown' if the expiration date is nil.

      def icon
        if expiration_date.nil? || expiration_date < 1.day.from_now
          "<i class='fa fa-warning'> </i>&nbsp"
        else
          ''
        end
      end

      def text
        return 'Unknown' if expiration_date.nil?
        distance_of_time_from_now = (expiration_date.to_time - Time.now).abs

        # We can't use time_ago_in_words for everything, because it's too
        # precise, e.g. it returns things like "5 minutes" and "about an hour".
        # But we don't need to care about expiry time with that much precision;
        # if it expires within 1 day of the present moment, simply stating the
        # day is precise enough.

        if distance_of_time_from_now < 1.day
          'Today'
        elsif distance_of_time_from_now < 2.days
          expiration_date > Time.now ? 'Tomorrow' : 'Yesterday'
        else
          words = time_ago_in_words(expiration_date)
          expiration_date > Time.now ? "In #{words}" : "#{words.capitalize} ago"
        end
      end
    end
  end
end
