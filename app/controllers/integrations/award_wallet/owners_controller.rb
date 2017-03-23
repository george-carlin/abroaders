module Integrations::AwardWallet
  class OwnersController < AuthenticatedUserController
    def update_person
      respond_to do |f|
        f.js { run Owner::Operation::UpdatePerson }
      end
    end
  end
end
