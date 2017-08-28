class ApplicationController < ActionController::Base
  include Abroaders::Controller::Onboarding

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Return the existing layout, or set a new one. ATM the only
  # alternative layout we have is 'basic'
  #
  # This overrides the 'normal' Rails way of setting layouts
  def self.layout(value = nil)
    if value.blank?
      @layout
    else
      @layout = value
    end
  end

  include I18nWithErrorRaising

  def dashboard
    if current_admin && !current_account
      render cell(Admin::Cell::Dashboard)
    elsif current_account
      redirect_if_not_onboarded! && return

      render cell(Account::Cell::Dashboard, current_account)
    else
      redirect_to new_account_session_path
    end
  end

  # Since upgrading to Ruby 2.4.0, rails prints warnings EVERYWHERE with
  # messages along the lines of "forwarding to private method
  # (Controller)#protect_against_forgery?". It seems that
  # protect_against_forgery?  is defined in actionpack as a private method of
  # ActionController::Base, but forwardable expects it to be public. Making the
  # method public may not be the ideal solution (really this is an issue in
  # rails that should be fixed, as far as I can tell), but it suppresses the
  # warnings:
  public :protect_against_forgery?

  private

  # cells has an existing system for 'layout' cells, with syntax like
  # this: `cell(MyCell, layout: MyLayout)`. However, I found this lacking
  # for a few reasons:
  #
  # 1. No way to pass options to the layout cell except by using context
  # 2. No good way to pass data (e.g. the page title) from the inner
  #    cell to the layout.
  #
  # This solution is a bit hacky but it gets the job done.
  def cell(klass, model = nil, options = {})
    cell_with_layout = super(
      Abroaders::Cell::Layout,
      super(klass, model, options),
      basic: self.class.layout == 'basic',
      flash: flash,
      current_account: current_account,
      current_admin: current_admin,
    )
    { html: cell_with_layout }
  end

  # Pass these options by default into Trailblazer operations when calling
  # them with 'run'.
  def _run_options(options)
    options['current_account'] = current_account if current_account
    options['current_admin'] = current_admin if current_admin
    options
  end

  # Show detailed error output to logged-in admins. Note that this only works
  # for 500 errors, not 404s. Also note that this method is only called when
  # config.consider_all_requests_local is false; when it's true (e.g.  in the
  # development environment), all requests show detailed exceptions anyway so
  # this method is irrelevant.
  def show_detailed_exceptions?
    !!current_admin
  end
end
