module Admin
  class CardAccountsController < AdminController

    def create
      @user   = find_user
      account = @user.card_accounts.build(card_account_params)
      account.status = :recommended
      accounts.recommended_at = Time.now
      account.save!
      redirect_to admin_user_path(@user)
    end

    private

    def card_account_params
      params.require(:card_account).permit(:card_id)
    end

    def find_user
      User.find(params[:user_id])
    end

  end
end
