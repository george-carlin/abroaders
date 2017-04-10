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
      run CardRecommendations::Complete do |result|
        flash[:success] = 'Sent notification!'
        redirect_to admin_person_path(result['person'])
        return
      end
      raise 'this should never happen!'
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
