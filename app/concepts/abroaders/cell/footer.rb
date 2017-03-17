module Abroaders
  module Cell
    class Footer < Base
      def show
        # The fixed position footer messes up tests because Capybara or
        # Poltergeist sometimes try to click on the footer instead of the
        # button/link beneath it. So don't show the footer in tests:
        return '' if Rails.env.test?
        render
      end
    end
  end
end
