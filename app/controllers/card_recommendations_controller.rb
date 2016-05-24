class CardRecommendationsController < CardAccountsController

  def update
    @account = CardAccount::UpdateStateForm.new(account: load_card_account)
    if @account.update(update_params)
      flash[:success] = t("card_accounts.flash.updated_status_to.#{@account.status}")
      redirect_to card_accounts_path
    else
      flash[:info] = t("card_accounts.index.couldnt_decline")
      redirect_to card_accounts_path
    end
  end

  def apply
    @account = load_card_account

    # Make sure this is the right type of card account:
    redirect_to card_accounts_path and return unless @account.applyable?

    # We can't know for sure here if the user has actually applied; the most we
    # can do is note that they've visited this page and (hopefully) been
    # redirected to the bank's page
    @account.update_attributes!(clicked_at: Time.now)
    @card = @account.card
  end

  private

  def load_card_account
    current_account.card_accounts.find(params[:id])
  end

  def decline_reason
    params[:card_account][:decline_reason]
  end

  def update_params
    result = params.require(:card_account).permit(
      :status, :decline_reason, :reconsidered
    )
    case result[:status]
    when "declined"
      result[:declined_at] = Date.today
    end
    result
  end

end
