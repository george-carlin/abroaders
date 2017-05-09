class LoyaltyAccount < LoyaltyAccount.superclass
  module Cell
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
