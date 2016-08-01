module API
  module V1
    class CardRecommendationsController < APIController

      def update
        survey = CardAccount::ApplicationSurvey.new(account: load_card_account)
        begin
          survey.update!(update_params)
          render json: survey.account, include: { card: :bank }
        rescue CardAccount::InvalidStatusError
          render json: {
            error: true,
            message: t("card_accounts.invalid_status_error"),
          }, code: 422
        end
      end

      private

      def load_card_account
        current_account.card_accounts.find(params[:id])
      end

      def update_params
        result = params.require(:card_account).permit(:action)
        if params[:card_account][:opened_at]
          result[:opened_at] = Date.strptime(params[:card_account][:opened_at], "%m/%d/%Y")
        end
        result
      end

    end
  end
end
