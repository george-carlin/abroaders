module Integrations::AwardWallet
  module User::Cell
    # @!method self.call(user)
    class Info < Abroaders::Cell::Base
      include Escaped

      property :id
      property :full_name
      property :user_name
      property :email
    end
  end
end
