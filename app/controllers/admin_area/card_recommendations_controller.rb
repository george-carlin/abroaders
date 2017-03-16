module AdminArea
  class CardRecommendationsController < AdminController
    def create
      run CardRecommendations::Operation::Create do
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
      @person = Person.find(params[:person_id])
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
      @recommendation = CardRecommendation.find(params[:id])
      @recommendation.pull!

      respond_to do |f|
        f.js
      end
    end

    def pulled
      run CardRecommendations::Operation::Pulled
      render cell(CardRecommendations::Cell::Pulled, result)
    end
  end
end
