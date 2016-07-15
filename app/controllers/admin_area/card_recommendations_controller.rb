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

    private

    def load_person
      Person.find(params[:person_id])
    end

  end
end
