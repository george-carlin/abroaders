class CardAccountsController < AuthenticatedUserController
  def new
    if params[:product_id]
      run CardAccount::New
      render cell(CardAccount::Cell::New, result)
    else
      run CardAccount::New::SelectProduct
      # TODO use new style, pass result to the cell directly
      collection = result['collection']
      render cell(CardAccount::Cell::New::SelectProduct, collection, banks: result['banks'])
    end
  end

  def create
    run CardAccount::Create do
      flash[:success] = 'Added card!'
      redirect_to cards_path
      return
    end
    render cell(CardAccount::Cell::New, result)
  end

  def edit
    run CardAccount::Edit
    @form.prepopulate!
  end

  def update
    run CardAccount::Update do
      flash[:success] = 'Updated card'
      return redirect_to cards_path
    end
    render :edit
  end

  def destroy
    run CardAccount::Destroy do
      flash[:success] = 'Removed card'
      return redirect_to cards_path
    end
    raise 'this should never happen'
  end
end
