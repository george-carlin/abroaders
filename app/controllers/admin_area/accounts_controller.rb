module AdminArea
  class AccountsController < AdminController
    # GET /admin/accounts
    def index
      person_assocs = [:spending_info]
      @accounts = Account.includes(
        people: person_assocs,
        owner: person_assocs,
        companion: person_assocs,
      ).order("email ASC")
    end

    # GET /admin/accounts/1
    def show
      @account = load_account
      @card_accounts = @account.card_accounts.select(&:persisted?)
      @card_recommendation = @account.card_accounts.new
      # Use @account.card_accounts here instead of @card_accounts because
      # the latter is an Array, not a Relation (because of
      # `.select(&:persisted?)`)
      @products = Card::Product.where.not(id: @account.card_accounts.select(:product_id))
    end

    def search
      @accounts = Account::Admin::Search.(query: params[:accounts][:search])
    end

    def download_user_status_csv
      csv = UserStatusCSV.generate
      send_data csv, filename: "user_status.csv", type: "text/csv", disposition: "attachment"
    end

    private

    def load_account
      Account.find(params[:id])
    end
  end
end
