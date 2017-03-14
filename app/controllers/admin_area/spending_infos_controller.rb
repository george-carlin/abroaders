module AdminArea
  class SpendingInfosController < AdminController
    def edit
      @person = ::Person.find(params[:person_id])
      @account = @person.account
      @model = @person.spending_info
      raise "person doesn't have spending info" unless @model
      @form = SpendingInfo::Form.new(@model)
    end

    def update
      @person  = ::Person.find(params[:person_id])
      @account = @person.account
      @model   = @person.spending_info
      raise "person doesn't have spending info" unless @model
      @form = SpendingInfo::Form.new(@model)
      if @form.validate(params[:spending_info])
        @form.save
        redirect_to admin_person_path(@person)
      else
        render :edit
      end
    end
  end
end
