class CardAccountsController < AuthenticatedUserController
  def new
    if params[:product_id]
      run CardAccount::New
      render cell(CardAccount::Cell::New, result)
    else
      # Use .joins so that we only get banks which have at least one product
      banks = Bank.all.joins(:card_products).group('banks.id').order(name: :asc)
      render cell(CardAccount::Cell::New::SelectProduct, banks)
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
