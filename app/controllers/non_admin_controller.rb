# Superclass for all controllers whose actions are intended to be used by
# logged-in 'normal', non-admin accounts.
class NonAdminController < AuthenticatedController

  before_action { redirect_to root_path if current_account.try(:admin?) }
  before_action :redirect_to_survey_if_incomplete

  protected

  def redirect_to_survey_if_incomplete
    if !current_account.has_added_passengers?
      if request.path != survey_passengers_path
        redirect_to survey_passengers_path
      end
      return
    end

    if !current_account.has_added_spending?
      if request.path != survey_spending_path
        redirect_to survey_spending_path
      end
      return
    end

    if !current_account.has_added_cards?
      if current_account.has_companion? && \
            current_main_passenger.has_added_cards?
        if request.path != survey_card_accounts_path(:companion)
          redirect_to survey_card_accounts_path(:companion)
        end
      else
        if request.path != survey_card_accounts_path(:main)
          redirect_to survey_card_accounts_path(:main)
        end
      end
      return
    end

    if !current_account.has_added_balances?
      if current_account.has_companion? && \
            current_main_passenger.has_added_balances?
        if request.path != survey_balances_path(:companion)
          redirect_to survey_balances_path(:companion)
        end
      else
        if request.path != survey_balances_path(:main)
          redirect_to survey_balances_path(:main)
        end
      end
      return
    end
  end
end
