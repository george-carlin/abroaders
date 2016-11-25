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
      @cards   = @account.cards.select(&:persisted?)
      @recommendation = @account.cards.new
      # Use @account.cards here instead of @cards because
      # the latter is an Array, not a Relation (because of
      # `.select(&:persisted?)`)
      @products = ::Card::Product.where.not(id: @account.cards.select(:product_id))
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
