module Integrations::AwardWallet
  class OwnersController < AuthenticatedUserController
    def update_person
      respond_to do |f|
        f.js do
          run Owner::Operation::UpdatePerson
          head :ok
        end
      end
    end
  end
end
