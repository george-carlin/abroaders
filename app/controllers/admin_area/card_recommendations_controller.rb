module AdminArea
  class CardRecommendationsController < AdminController
    def create
      person = load_person
      rec = AdminArea::CardRecommendation.new(person: person)
      rec.update_attributes!(card_rec_params)
      respond_to do |f|
        f.js do
          @card = rec.card
          @offer = rec.offer
        end
      end
    end

    def complete
      @person = load_person
      form = CompleteCardRecommendations.create!(
        note:   params[:recommendation_note],
        person: @person,
      )
      Notifications::NewRecommendations.notify!(@person)
      CardRecommendationsMailer.recommendations_ready(
        account_id: form.account.id,
        note:       form.note,
      ).deliver_later
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

    def card_rec_params
      params.require(:card_recommendation).permit(:offer_id)
    end

    def load_person
      Person.find(params[:person_id])
    end

    def load_recommendation
      Card.recommendations.find(params[:id])
    end

    def recommendation_note
      params[:recommendation_note]
    end
  end
end
