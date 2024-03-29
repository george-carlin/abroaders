module AdminArea
  class CurrenciesController < AdminController
    def index
      currencies = Currency.all.order(:name)
      render cell(Currencies::Cell::Index, currencies)
    end

    def new
      run Currencies::New
      render cell(Currencies::Cell::New, @model, form: @form)
    end

    def create
      run Currencies::Create do
        flash[:success] = 'Created new currency!'
        redirect_to admin_currencies_path
        return
      end
      render cell(Currencies::Cell::New, @model, form: @form)
    end

    def edit
      run Currencies::Edit
      render cell(Currencies::Cell::Edit, @model, form: @form)
    end

    def update
      run Currencies::Update do
        flash[:success] = 'Updated currency'
        redirect_to admin_currencies_path
        return
      end
      render cell(Currencies::Cell::Edit, @model, form: @form)
    end
  end
end
