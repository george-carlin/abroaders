module AdminArea
  class CardsController < AdminController
    def new
      form ::Card::Admin::Create
      @products = load_products_for_select
    end

    def create
      run ::Card::Admin::Create do
        flash[:success] = 'Added card!'
        return redirect_to admin_person_path(@model.person)
      end
      @products = load_products_for_select
      render :new
    end

    def edit
      form ::Card::Admin::Update
    end

    def update
      run ::Card::Admin::Update do
        flash[:success] = 'Added card!'
        return redirect_to admin_person_path(@model.person)
      end
      @products = load_products_for_select
      render :new
    end

    private

    # TODO argh this is terrible
    def load_products_for_select
      ::Card::Product.all.map do |product|
        [::Card::Product::Identifier.new(product).to_s, product.id]
      end.sort_by { |p| p[0] }
    end
  end
end
