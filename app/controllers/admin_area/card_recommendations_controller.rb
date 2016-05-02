module AdminArea
  class CardRecommendationsController < AdminController

    def new
      @person = find_person
      person_must_be_onboarded! and return
      @account       = @person.account
      @spending_info = @person.spending_info
      accounts = @person.card_accounts.includes(:card)
      # Call 'to_a' so it doesn't include @card_recommendation:
      @card_accounts = accounts.to_a
      @card_recommendation = accounts.recommendations.build
      @offers_grouped_by_card = \
        Offer.includes(:card, card: :currency).live.group_by(&:card)
      @balances     = @person.balances.includes(:currency)
      @travel_plans = @account.travel_plans
    end

    def create
      @person = find_person
      person_must_be_onboarded! and return
      @account   = @person.account
      # TODO don't allow expired/inactive offers to be assigned:
      @offer =  Offer.find(params[:offer_id])
      @person.recommend_offer!(@offer)
      flash[:success] = "Recommended card!"
      # TODO notify person
      redirect_to new_admin_person_card_recommendation_path(@person)
    end

    private

    def find_person
      Person.find(params[:person_id])
    end

    def person_must_be_onboarded!
      if @person.onboarded?
        false
      else
        flash[:error] = t("admin.people.card_recommendations.not_onboarded")
        redirect_to admin_person_path(@person)
        true
      end
    end

  end
end
