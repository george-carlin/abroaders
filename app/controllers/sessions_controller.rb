class SessionsController < Devise::SessionsController
  before_action :redirect_admins!

  layout 'basic'

  def new
    account = Account.new(sign_in_params)
    account.clean_up_passwords
    render cell(Sessions::Cell::New, account)
  end

  # no need to override #create to make it use the Cell; failed sign ins
  # redirect to #new rather than rendering from within #create

  private

  def after_sign_in_path_for(account)
    if account.onboarded?
      root_path
    else
      # This should kick off some extra redirects until they get to where
      # they're supposed to be. Not the ideal system as it results in a bunch
      # of extra HTTP requests which we could reduce to just one, but it will
      # do for now.
      new_travel_plan_path
    end
  end

  def redirect_admins!
    return unless current_admin
    flash[:notice] = "You must sign out of your admin account before "\
      "you can sign in as a regular user"
    redirect_to root_path
  end
end
