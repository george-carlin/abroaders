module AdminArea
  class CardsController < AdminController
    def new
      run AdminArea::Card::Operation::New
      @products = AdminArea::Card::Operation::New.product_options
    end

    def create
      run AdminArea::Card::Operation::Create do
        flash[:success] = 'Added card!'
        return redirect_to admin_person_path(@model.person)
      end
      @products = AdminArea::Card::Operation::New.product_options
      render :new
    end

    def edit
      run ::AdminArea::Card::Operation::Edit
      @form.prepopulate!
    end

    def update
      run ::AdminArea::Card::Operation::Update do
        flash[:success] = 'Updated card!'
        return redirect_to admin_person_path(@model.person)
      end
      @products = AdminArea::Card::Operation::Edit.product_options
      render :new
    end
  end
end
