module AdminArea
  class CardsController < AdminController
    def new
      run AdminArea::Card::Operations::New
      @products = AdminArea::Card::Operations::New.product_options
    end

    def create
      run AdminArea::Card::Operations::Create do
        flash[:success] = 'Added card!'
        return redirect_to admin_person_path(@model.person)
      end
      @products = AdminArea::Card::Operations::New.product_options
      render :new
    end

    def edit
      run ::AdminArea::Card::Operations::Edit
      @form.prepopulate!
    end

    def update
      run ::AdminArea::Card::Operations::Update do
        flash[:success] = 'Updated card!'
        return redirect_to admin_person_path(@model.person)
      end
      @products = AdminArea::Card::Operations::Edit.product_options
      render :new
    end
  end
end
