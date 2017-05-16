class PasswordsController < ApplicationController
  layout 'basic'

  # GET /accounts/password/new
  def new
    render cell(Password::Cell::New, Account.new)
  end

  # POST /accounts/password
  def create
    run Password::SendResetInstructions do
      flash[:notice] = I18n.t("devise.passwords.send_instructions")
      return redirect_to new_account_session_path
    end
    render cell(Password::Cell::New, @model)
  end

  # GET /accounts/password/edit?reset_password_token=abcdef
  def edit
    account = Account.new(reset_password_token: params[:reset_password_token])
    render cell(Password::Cell::Edit, account)
  end

  # PUT /accounts/password
  def update
    account = Account.reset_password_by_token(params[:account])

    if account.errors.empty?
      flash[:notice] = I18n.t("devise.passwords.updated")
      sign_in(:account, account)
      redirect_to root_path
    else
      render cell(Password::Cell::Edit, account)
    end
  end
end
