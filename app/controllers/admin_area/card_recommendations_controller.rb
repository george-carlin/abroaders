module AdminArea
  class CardRecommendationsController < AdminController
    def create
      run CardRecommendations::Create do
        respond_to(&:js)
        return
      end
      raise 'this should never happen!'
    end

    def edit
      run CardRecommendations::Edit
      # See notes on this in CardAccountsController
      @form = result['contract.default']
      render cell(CardRecommendations::Cell::Edit, @model, form: @form)
    end

    def update
      run CardRecommendations::Update do
        flash[:success] = 'Updated rec!'
        return redirect_to admin_person_path(@model.person)
      end
      # See notes on this in CardAccountsController
      @form = result['contract.default']
      @form.prepopulate!
      render cell(CardRecommendations::Cell::Edit, @model, form: @form)
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
      # Not bothering with an Operation here because this entire action will be
      # removed soon:
      @recommendation = Card.recommended.find(params[:id])
      @recommendation.update!(pulled_at: Time.zone.now)

      respond_to do |f|
        f.js
      end
    end
  end
end
