class CardAccountsController < AuthenticatedUserController
  def new
    if params[:card_product_id]
      run CardAccount::New
      render cell(CardAccount::Cell::New, @model, form: @form)
    else
      banks = Bank.with_at_least_one_product.sort_by(&:name)
      render cell(CardAccount::Cell::New::SelectProduct, banks)
    end
  end

  def create
    run CardAccount::Create do
      flash[:success] = 'Added card!'
      redirect_to cards_path
      return
    end
    render cell(CardAccount::Cell::New, @model, form: @form)
  end

  def edit
    run CardAccount::Edit
    @form.prepopulate!
    render cell(CardAccount::Cell::Edit, @model, form: @form)
  end

  def update
    run CardAccount::Update do
      flash[:success] = 'Updated card'
      return redirect_to cards_path
    end
    render cell(CardAccount::Cell::Edit, @model, form: @form)
  end

  def destroy
    run CardAccount::Destroy do
      flash[:success] = 'Removed card'
      return redirect_to cards_path
    end
    raise 'this should never happen'
  end
end
