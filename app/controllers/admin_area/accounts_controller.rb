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
      @account = Account.includes(
        home_airports: :parent,
        travel_plans: [flights: [:from, :to]], balances: :currency,
        owner: [:spending_info, card_accounts: [card: [:currency]]],
        companion: [:spending_info, card_accounts: [card: [:currency]]],
      ).find(params[:id])

      @alliances = Alliance.all
      @banks = Bank.all

      @independent_currencies = Currency.independent.filterable.order(name: :asc)

      @offers = Offer.includes(card: :currency).live
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
