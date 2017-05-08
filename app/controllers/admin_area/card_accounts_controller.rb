module AdminArea
  class CardAccountsController < AdminController
    def new
      run CardAccounts::New
      @form = result['contract.default']
    end

    def create
      run CardAccounts::Create do
        flash[:success] = 'Added card!'
        return redirect_to admin_person_path(@model.person)
      end
      @form = result['contract.default']
      render :new
    end

    def edit
      run CardAccounts::Edit
      @form = result['contract.default']
      @form.prepopulate!
    end

    def update
      run CardAccounts::Update do
        flash[:success] = 'Updated card!'
        return redirect_to admin_person_path(@model.person)
      end
      @form = result['contract.default']
      render :edit
    end
  end
end
