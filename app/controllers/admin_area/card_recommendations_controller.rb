module AdminArea
  class CardRecommendationsController < AdminController

    def create
      @person = load_person
      # TODO don't allow expired/inactive offers to be assigned:
      offer = Offer.find(params[:offer_id])
      @person.card_recommendations.create!(offer: offer, recommended_at: Time.now)
      flash[:success] = "Recommended card!"
      redirect_to admin_person_path(@person)
    end

    def complete
      @person = load_person
      CompleteCardRecommendations.create!(
        person: @person,
        note:   params[:recommendation_note],
      )
      flash[:success] = "Sent notification!"
      redirect_to admin_person_path(@person)
    end

    def pull
      @recommendation = load_recommendation
      @recommendation.pull!

      respond_to do |f|
        f.js
      end
    end

    def pulled
      @person  = load_person
      @account = @person.account
      @pulled_recommendations = @person.card_recommendations.pulled
    end

    private

    def load_person
      Person.find(params[:person_id])
    end

    def load_recommendation
      CardAccount.recommendations.find(params[:id])
    end

  end
end
