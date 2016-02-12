module Admin
  class CardRecommendationsController < Admin::CardAccountsController

    def new
      @user = find_user
      user_must_have_completed_onboarding_survey!
      accounts = @user.card_accounts.includes(:card)
      # Call 'to_a' so it doesn't include @card_recommendation:
      @card_accounts = accounts.to_a
      @card_recommendation = accounts.recommendations.build
      @card_offers_grouped_by_card = \
        CardOffer.includes(:card, card: :currency).all.group_by(&:card)
      @balances = @user.balances.includes(:currency)
      @travel_plans = @user.travel_plans
    end

    def create
      @user  = find_user
      user_must_have_completed_onboarding_survey!
      # TODO don't allow expired/inactive offers to be assigned:
      @offer =  CardOffer.find(params[:offer_id])
      @user.card_recommendations.create!(
        recommended_at: Time.now,
        offer: @offer
      )
      flash[:success] = "Recommended card to user!"
      # TODO notify user
      redirect_to new_admin_user_card_recommendation_path(@user)
    end

    private

    def user_must_have_completed_onboarding_survey!
      unless @user.survey_complete?
        flash[:error] = t("admin.users.card_recommendations.no_survey")
        redirect_to admin_user_path(@user)
      end
    end
  end
end
