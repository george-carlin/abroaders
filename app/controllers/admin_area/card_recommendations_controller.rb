module AdminArea
  class CardRecommendationsController < AdminController
    def create
      run AdminArea::CardRecommendation::Operation::Create do
        respond_to do |f|
          f.js do
            @card  = @model
            @offer = @model.offer
          end
        end
        return
      end
      raise 'this should never happen!'
    end

    def complete
      @person = load_person
      # form = CompleteRecommendations.create!(
      CompleteRecommendations.create!(
        note:   params[:recommendation_note],
        person: @person,
      )
      Notifications::NewRecommendations.notify!(@person)
      # RecommendationsMailer.recommendations_ready(
      #   account_id: form.account.id,
      # ).deliver_later
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
      warn "#{self.class}#{__method__} needs extracting to a TRB op"
      person = ::Person.find(params[:person_id])
      # fake a TRB result op for future-compatibility:
      @_result = {
        'account'    => person.account,
        'collection' => person.card_recommendations.pulled,
        'person'     => person,
      }
      render cell(AdminArea::CardRecommendation::Cell::Pulled, result)
    end

    private

    def recommendation_params
      params.require(:recommendation).permit(:offer_id)
    end

    def load_person
      ::Person.find(params[:person_id])
    end

    def load_recommendation
      ::CardRecommendation.find(params[:id])
    end

    def recommendation_note
      params[:recommendation_note]
    end
  end
end
