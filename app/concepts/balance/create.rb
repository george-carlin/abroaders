require 'reform/form/dry'

class Balance < Balance.superclass
  class Create < Trailblazer::Operation
    step Nested(New)
    success :setup_person!
    step Contract::Validate(key: :balance)
    step Contract::Persist()

    private

    # If the account is a couples account, then person ID MUST be present, and
    # an error will be raised if the person_id doesn't belong to them.  If the
    # account is a solo account, then any given person ID will be ignored, and
    # the balance's person_id will be the account owner.
    def setup_person!(current_account:, params:, **)
      if current_account.couples?
        if params[:balance][:person_id].present?
          # make sure it's their person; this will raise an error if it's not:
          current_account.people.find(params[:balance][:person_id])
        end
      else # ignore whatever they said and set it to the owner:
        params[:balance][:person_id] = current_account.owner.id
      end
    end
  end
end
