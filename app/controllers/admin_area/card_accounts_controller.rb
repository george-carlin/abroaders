module AdminArea
  class CardAccountsController < AdminController
    def new
      run CardAccounts::New
      @products = CardAccounts::New.product_options
    end

    def create
      run CardAccounts::Create do
        flash[:success] = 'Added card!'
        return redirect_to admin_person_path(@model.person)
      end
      @products = CardAccounts::New.product_options
      render :new
    end

    def edit
      run CardAccounts::Edit
      @form.prepopulate!
    end

    def update
      run CardAccounts::Update do
        flash[:success] = 'Updated card!'
        return redirect_to admin_person_path(@model.person)
      end
      render :edit
    end
  end
end
