module Admin
  class CardRecommendationsController < CardAccountsController

    def new
      @user = find_user
      user_must_have_completed_onboarding_survey!
      # Call 'to_a' so it doesn't include @card_recommendation
      @card_accounts = @user.card_accounts.to_a
      @card_recommendation = @user.card_accounts.recommendations.build
      @card_offers_grouped_by_card = CardOffer.all.group_by(&:card)
    end

    def create
      @user  = find_user
      user_must_have_completed_onboarding_survey!
      # TODO don't allow expired/inactive offers to be assigned:
      @offer =  CardOffer.find(params[:offer_id])
      @user.card_recommendations.create!(
        recommended_at: Time.now,
        offer: @offer,
        # TODO figure this out automatically within CardAccount:
        card:  @offer.card
      )
      flash[:success] = "Recommended card to user!"
      # TODO notify user
      redirect_to new_admin_user_card_recommendation_path(@user)
    end

    private

    def user_must_have_completed_onboarding_survey!
      if @user.info.nil? # TODO change to 'completed onboarding?'
        flash[:error] = t("admin.users.card_recommendations.no_survey")
        redirect_to admin_user_path(@user)
      end
    end
  end
end
