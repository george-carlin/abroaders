module Abroaders
  module Cell
    # This cell will be rendered just before the closing <body> tag on every
    # page. Use it to render third party scripts, e.g. the Google Analytics JS
    # snippet.
    #
    # To add a new script:
    #
    # 1. Put it in a file called:
    #
    #       app/concepts/abroaders/cell/third_party_scripts/my_script.erb
    #
    #    (make sure to include the wrapping <script> tag)
    #
    # 2. Add the string 'my_script' to the arraw in the #show method below
    class ThirdPartyScripts < Abroaders::Cell::Base
      def show
        return '' if ENV['DISABLE_THIRD_PARTY_SCRIPTS']
        %w[
          fb_tracking_pixel
          google_analytics
          heap
          post_affiliate_pro
        ].map { |path| render view: "third_party_scripts/#{path}" }.join
      end

      private

      # We need to run a Javascript snippet immediately after a user signs up -
      # but we need to make sure it doesn't get run again if they e.g. refresh
      # the page. The hacky solution below will do for now:

      def fb_tracked?
        !!cookies[fb_tracking_cookie_key]
      end

      def fb_tracked!
        cookies[fb_tracking_cookie_key] = true
      end

      def fb_tracking_cookie_key
        # Use a meaningless name to obfuscate the cookie's purpose:
        :cbd50008665cc7269327074d2778d9a6
      end

      def fb_tracking_pixel_post_sign_up?
        # If a) we're on the first page after signing up and b) the cookie
        # isn't present that indicates that this user has been tracked.  then
        # output the 'CompleteRegistration' FB tracking <script>
        !fb_tracked? && request.path == survey_home_airports_path
      end
    end
  end
end
