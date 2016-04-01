module AdminArea
  class CardRecommendationsController < AdminArea::CardAccountsController

    def new
      @passenger = find_passenger
      # passenger_must_have_completed_onboarding_survey!
      @account       = @passenger.account
      @spending_info = @passenger.spending_info
      accounts = @passenger.card_accounts.includes(:card)
      # Call 'to_a' so it doesn't include @card_recommendation:
      @card_accounts = accounts.to_a
      @card_recommendation = accounts.recommendations.build
      @card_offers_grouped_by_card = \
        CardOffer.includes(:card, card: :currency).all.group_by(&:card)
      @balances     = @passenger.balances.includes(:currency)
      @travel_plans = @account.travel_plans
    end

    def create
      @passenger = find_passenger
      @account   = @passenger.account
      passenger_must_have_completed_onboarding_survey!
      # TODO don't allow expired/inactive offers to be assigned:
      @offer =  CardOffer.find(params[:offer_id])
      @passenger.card_recommendations.create!(
        recommended_at: Time.now,
        offer: @offer
      )
      flash[:success] = "Recommended card to passenger!"
      # TODO notify passenger
      redirect_to new_admin_passenger_card_recommendation_path(@passenger)
    end

    private

    def find_passenger
      Passenger.find(params[:passenger_id])
    end

    def passenger_must_have_completed_onboarding_survey!
      unless @account.onboarded?
        flash[:error] = t("admin.passengers.card_recommendations.no_survey")
        redirect_to admin_passenger_path(@passenger)
      end
    end
  end
end
