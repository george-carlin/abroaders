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
      render cell(CardRecommendations::Cell::Edit, @model, form: @form)
    end

    def update
      run CardRecommendations::Update do
        flash[:success] = 'Updated rec!'
        return redirect_to admin_person_path(@model.person)
      end
      @form.prepopulate!
      render cell(CardRecommendations::Cell::Edit, @model, form: @form)
    end

    def destroy
      rec = Card.recommended.find(params[:id])
      rec.destroy
      flash[:success] = 'Deleted recommendation'
      redirect_back(fallback_location: admin_person_path(rec.person))
    end

    def complete
      run CardRecommendations::Complete do |result|
        flash[:success] = 'Recs done! Requests are now marked as resolved'
        redirect_to admin_person_path(result['person'])
        return
      end
      raise 'this should never happen!'
    end
  end
end
