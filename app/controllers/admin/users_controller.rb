module Admin
  class AccountsController < AdminController

    # GET /admin/accounts
    def index
      @accounts = Account.includes(:survey).non_admin
    end

    # GET /admin/accounts/1
    def show
      @account = get_account
      @card_accounts = @account.card_accounts.select(&:persisted?)
      @card_recommendation = @account.card_accounts.new
      # Use @account.card_accounts here instead of @card_accounts because
      # the latter is an Array, not a Relation (because of
      # `.select(&:persisted?)`)
      @cards = Card.where.not(id: @account.card_accounts.select(:card_id))
    end

    # GET /admin/accounts/new
    def new
      raise "not yet implemented"
      @account = Account.new
    end

    # GET /admin/accounts/1/edit
    def edit
      raise "not yet implemented"
      @account = get_account
    end

    # POST /admin/accounts
    def create
      raise "not yet implemented"
      @account = Account.new(account_params)

      if @account.save
        redirect_to @account, notice: 'Account was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /admin/accounts/1
    def update
      raise "not yet implemented"
      @account = get_account
      if @account.update(account_params)
          redirect_to @account, notice: 'Account was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /admin/accounts/1
    def destroy
      raise "not yet implemented"
      @account = get_account
      @account.destroy
      redirect_to accounts_url, notice: 'Account was successfully destroyed.'
    end

    private

    def get_account
      Account.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def account_params
      params[:account]
    end
  end
end
