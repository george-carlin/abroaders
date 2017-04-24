module Abroaders
  module Cell
    class Noscript < Abroaders::Cell::Base
      def show
        return '' if Rails.env.test?
        super
      end
    end
  end
end
