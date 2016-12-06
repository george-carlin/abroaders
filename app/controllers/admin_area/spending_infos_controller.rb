module AdminArea
  class SpendingInfosController < AdminController
    def edit
      @person  = Person.find(params[:person_id])
      @account = @person.account
      @model   = @person.spending_info
      raise "person doesn't have spending info" unless @model
      @form = EditSpendingInfoForm.load(@person)
    end

    def update
      @person  = Person.find(params[:person_id])
      @account = @person.account
      @model   = @person.spending_info
      raise "person doesn't have spending info" unless @model
      @form = EditSpendingInfoForm.load(@person)
      if @form.update(spending_info_params)
        redirect_to admin_person_path(@person)
      else
        render :edit
      end
    end

    private

    def spending_info_params
      params.require(:spending_info).permit(
        :monthly_spending_usd,
        :person,
        :monthly_spending_usd,
        :business_spending_usd,
        :credit_score,
        :has_business,
        :will_apply_for_loan,
      )
    end
  end
end
