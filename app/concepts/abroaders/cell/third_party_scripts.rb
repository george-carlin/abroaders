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
    end
  end
end
