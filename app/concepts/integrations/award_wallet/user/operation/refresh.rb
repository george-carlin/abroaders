module Integrations
  module AwardWallet
    module User
      module Operation
        class Refresh < Trailblazer::Operation
          # get the data from the API
          # begin transaction
          # update the user
          # for each account:
          #   if we already have it:
          #     if the owner has changed to something we don't recognise:
          #       create the owner
          #     update the attrs
          #   if we don't already have it:
          #     create the owner if necessary
          #     update the attrs
          #     create the account
          # end transaction
        end
      end
    end
  end
end
