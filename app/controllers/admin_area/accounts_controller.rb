module AdminArea
  class AccountsController < AdminController
    # GET /admin/accounts
    def index
      run Accounts::Operation::Index
      render cell(Accounts::Cell::Index, result['accounts'], page: params[:page])
    end

    # GET /admin/accounts/1
    def show
      run Accounts::Operation::Show
    end

    def search
      run Accounts::Operation::Search
      render cell(Accounts::Cell::Search, result)
    end
  end
end
