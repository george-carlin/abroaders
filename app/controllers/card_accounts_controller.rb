class CardAccountsController < AuthenticatedUserController
  def new
    if params[:card_product_id]
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
    run CardAccount::Edit do |result|
      # `run` sets @form to an instance of Trailblazer::Rails::Form, which wraps
      # result['contract.default']. However, for some reason T::R::F ignores the
      # 'model' option that's set in the form object class, meaning form_for
      # generates inputs with the wrong names. Not sure if this is a bug with
      # trailblazer-rails or a deliberate design choice.
      #
      # Whatever the case, forget T::R::Form for now:
      @form = result['contract.default']
      @form.prepopulate!
    end
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
