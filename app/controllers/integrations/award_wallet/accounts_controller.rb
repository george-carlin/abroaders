module Integrations::AwardWallet
  class AccountsController < ApplicationController
    def edit
      run Account::Edit
      render cell(Account::Cell::Edit, @form)
    end

    def update
      run Account::Update do
        flash[:success] = 'Update succesful!'
        return redirect_to balances_path
      end
      render cell(Account::Cell::Edit, @form)
    end
  end
end