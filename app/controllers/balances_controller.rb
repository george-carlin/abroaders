class BalancesController < NonAdminController

  def survey
    @currencies = Currency.all
  end

  # TODO this needs better error handling
  def save_survey
    # Example params:
    # { balances: [{currency_id: 2, value: 100}, {currency_id: 6, value: 500}] }
    ApplicationRecord.transaction do
      current_user.balances.create!(balances_params)
      current_user.update_attributes!(has_completed_balances_survey: true)
    end
    redirect_to root_path
  end

  private

  # Can't figure out how to s
  def balances_params
    params.permit(balances: [:currency_id, :value])[:balances] || []
  end

end
