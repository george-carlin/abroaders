module AdminArea
  class AccountsController < AdminController
    include Auth::Controllers::SignInOut

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

    def inspect
      if current_account
        flash[:error] = 'Already signed in as a user'
        redirect_to :back
      end

      account = Account.find(params[:id])
      sign_in(:account, account)
      redirect_to root_path
    end
  end
end
