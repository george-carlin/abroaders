module Integrations::AwardWallet
  module User::Cell
    # @!method self.call(user)
    class Info < Trailblazer::Cell
      include Escaped

      property :id
      property :full_name
      property :user_name
      property :email
    end
  end
end
