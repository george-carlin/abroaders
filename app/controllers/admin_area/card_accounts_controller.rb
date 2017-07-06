module AdminArea
  class CardAccountsController < AdminController
    def new
      run CardAccounts::New
      render cell(CardAccounts::Cell::New, @model, form: @form)
    end

    def create
      run CardAccounts::Create do
        flash[:success] = 'Added card!'
        return redirect_to admin_person_path(@model.person)
      end
      render cell(CardAccounts::Cell::New, @model, form: @form)
    end

    def edit
      run CardAccounts::Edit
      @form.prepopulate!
      render cell(CardAccounts::Cell::Edit, @model, form: @form)
    end

    def update
      run CardAccounts::Update do
        flash[:success] = 'Updated card!'
        return redirect_to admin_person_path(@model.person)
      end
      render cell(CardAccounts::Cell::Edit, @model, form: @form)
    end
  end
end
