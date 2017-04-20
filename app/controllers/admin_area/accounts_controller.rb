module AdminArea
  class AccountsController < AdminController
    # GET /admin/accounts
    def index
      accounts = Account.includes(
        people: :spending_info,
        owner: :spending_info,
        companion: :spending_info,
      ).order("email ASC")
      render cell(Accounts::Cell::Index, accounts, page: params[:page])
    end

    def search
      run Accounts::Search
      render cell(Accounts::Cell::Search, result)
    end
  end
end
