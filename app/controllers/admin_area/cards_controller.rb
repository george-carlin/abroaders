module AdminArea
  class CardsController < AdminController
    def new
      run Cards::Operation::New
      @products = Cards::Operation::New.product_options
    end

    def create
      run Cards::Operation::Create do
        flash[:success] = 'Added card!'
        return redirect_to admin_person_path(@model.person)
      end
      @products = Cards::Operation::New.product_options
      render :new
    end

    def edit
      run Cards::Operation::Edit
      @form.prepopulate!
    end

    def update
      run Cards::Operation::Update do
        flash[:success] = 'Updated card!'
        return redirect_to admin_person_path(@model.person)
      end
      @products = Cards::Operation::Edit.product_options
      render :new
    end
  end
end
