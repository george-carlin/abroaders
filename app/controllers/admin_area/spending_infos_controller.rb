module AdminArea
  class SpendingInfosController < AdminController
    def edit
      person = ::Person.find(params[:person_id])
      model = person.spending_info
      raise "person doesn't have spending info" unless model
      form = SpendingInfo::Form.new(model)
      render cell(SpendingInfos::Cell::Edit, model, form: form)
    end

    def update
      person = ::Person.find(params[:person_id])
      model = person.spending_info
      raise "person doesn't have spending info" unless model
      form = SpendingInfo::Form.new(model)
      if form.validate(params[:spending_info])
        form.save
        redirect_to admin_person_path(person)
      else
        render cell(SpendingInfos::Cell::Edit, model, form: form)
      end
    end
  end
end
