module AdminArea
  class RecommendationNotesController < AdminController
    # Admins can update rec notes. The edit/update actions here are pretty
    # primitive and don't follow our best standards, but it doesn't matter.
    # We're probably going to replace the current recommendation note system
    # entirely, once the 'recommendation request' system is ready. In the
    # meantime I just needed to throw up something quickliy for admins to edit
    # existing notes now.

    class Form < Reform::Form
      model :recommendation_note

      property :content
    end

    def edit
      @model = RecommendationNote.find(params[:id])
      @form  = Form.new(@model)
      render cell(RecommendationNotes::Cell::Edit, @model, form: @form)
    end

    def update
      @model = RecommendationNote.find(params[:id])
      @form  = Form.new(@model)
      if @form.validate(params[:recommendation_note])
        @form.save
        flash[:success] = 'Updated rec note'
        redirect_to admin_person_path(params[:person_id])
        return
      else
        render cell(RecommendationNotes::Cell::Edit, @model, form: @form)
      end
    end
  end
end
