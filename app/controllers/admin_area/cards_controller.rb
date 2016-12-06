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

    private

    def params!(params)
      params[:person] = Person.find(params[:person_id])
      params
    end

    # TODO argh this is terrible
    def load_products_for_select
      ::Card::Product.all.map do |product|
        [::Card::Product::Identifier.new(product).to_s, product.id]
      end.sort_by { |p| p[0] }
    end
  end
end
