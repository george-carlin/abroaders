module AdminArea
  class AccountsController < AdminController

    # GET /admin/accounts/:id
    def show
      @account = Account.includes(
        home_airports: :parent,
        travel_plans: [flights: [:from, :to]], balances: :currency,
        owner: :spending_info, companion: :spending_info
      ).find(params[:id])

      @alliances = Alliance.all

      @card_accounts = @account.card_accounts.select(&:persisted?)
      @card_recommendation = @account.card_accounts.new
      # Use @account.card_accounts here instead of @card_accounts because
      # the latter is an Array, not a Relation (because of
      # `.select(&:persisted?)`)
      @cards = Card.where.not(id: @account.card_accounts.select(:card_id))
    end

    # GET /admin/accounts
    def index
      person_assocs = [:spending_info]
      @accounts = Account.includes(
        people: person_assocs,
        owner: person_assocs, companion: person_assocs,
      ).order("email ASC")
    end

    def download_user_status_csv
      csv = UserStatusCSV.generate
      send_data csv, filename: "user_status.csv", type: "text/csv", disposition: "attachment"
    end

    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def account_params
      params[:account]
    end
  end
end
