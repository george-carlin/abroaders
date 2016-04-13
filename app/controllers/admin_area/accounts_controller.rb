module AdminArea
  class AccountsController < AdminController

    # GET /admin/accounts
    def index
      @accounts = Account\
        .includes(:people, :main_passenger, :companion)\
        .order("email ASC")
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
