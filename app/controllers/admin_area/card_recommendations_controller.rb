module AdminArea
  class CardRecommendationsController < AdminController
    def create
      run CardRecommendations::Operation::Create do
        respond_to(&:js)
        return
      end
      raise 'this should never happen!'
    end

    def complete
      run CardRecommendations::Operation::Complete do |result|
        flash[:success] = 'Sent notification!'
        redirect_to admin_person_path(result['person'])
        return
      end
      raise 'this should never happen!'
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
      render cell(CardRecommendations::Cell::Pulled, result)
    end

    private

    def recommendation_params
      params.require(:recommendation).permit(:offer_id)
    end

    def load_person
      ::Person.find(params[:person_id])
    end

    def load_recommendation
      CardRecommendation.find(params[:id])
    end

    def recommendation_note
      params[:recommendation_note]
    end
  end
end
