class Account < Account.superclass
  module Cell
    # model: an Account. returns the accounts signup date in the format m/d/y
    class SignedUp < Abroaders::Cell::Base
      property :created_at

      def show
        created_at.strftime('%D')
      end
    end
  end
end
