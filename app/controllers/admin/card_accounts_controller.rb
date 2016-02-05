module Admin
  class CardAccountsController < AdminController

    def create
      raise "Not yet implemented"

      # This is the old implementation from before we split out
      # CardRecommendationsController:
      @user = find_user

      @account = @user.card_accounts.build(card_account_params)
      case params[:create_mode]
      when "recommendation"
        @account.status = :recommended
        @account.recommended_at = Time.now
        message = "Recommended card to user"
      when "assignment"
        @account.status = params[:card_account][:status]
        message = "Assigned card to user"
      else
        raise "unrecognized create_mode"
      end

      @account.save!

      flash[:success] = message

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
