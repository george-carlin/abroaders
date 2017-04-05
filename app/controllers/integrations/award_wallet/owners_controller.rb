module Integrations::AwardWallet
  class OwnersController < AuthenticatedUserController
    def update_person
      respond_to do |f|
        f.js { run Owner::UpdatePerson }
      end
    end
  end
end
