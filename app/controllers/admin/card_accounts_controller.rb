module Admin
  class CardAccountsController < AdminController

    def create
      @user   = User.find(params[:user_id])
      account = @user.card_accounts.build(card_account_params)
      account.status = :recommended
      account.save!
      redirect_to admin_user_path(@user)
    end

    private

    def card_account_params
      params.require(:card_account).permit(:card_id)
    end

  end
end
