class ApplicationController < ActionController::Base
  include Abroaders::Controller::Onboarding
  include Auth::Controllers::UrlHelpers
  include Auth::Controllers::Helpers

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_action :warn_if_no_trb

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

  # Extend `render` (which is already being extended by the trailblazer-rails
  # gem to allow Cells to be rendered directly without going through the
  # ActionView layer) so that if you're directly rendering a cell from the
  # controller and the cell responds to `title` (that's as an instance method,
  # not a class method - `render` deals with instances of the cell, not the
  # cell's class), then the return value of `title` will be stored in an ivar
  # `@cell_title`. This ivar will be used later by TitleHelper to fill the
  # page's <title> tag.
  #
  # This is the solution, for now, to how we can provide custom <title>s for
  # cell-based pages when the <title> tag itself lives in an ActionView
  # template. (The standard AV approach with `provide` doesn't work, or at
  # least I couldn't get it to work.) This is kinda hacky but I can't see a
  # better way for now. If we ever manage to completely remove the ActionView
  # layer and use Cells for everything including the layout, we can probably
  # remove this override:
  def render(cell = nil, opts = {}, *, &block)
    if cell.is_a?(::Cell::ViewModel) && cell.respond_to?(:title)
      @cell_title = cell.title
    end
    super
  end

  # Pass in current account or admin as cell context.
  def cell(klass, model = nil, options = {})
    return super if (current_account || current_admin).nil?
    options[:context] ||= {}
    options[:context][:current_account] = current_account
    options[:context][:current_admin] = current_admin

    super(klass, model, options)
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

  # Pass these options by default into Trailblazer operations when calling
  # them with 'run'.
  #
  # This needs to live here rather than AuthenticatedUserController so that
  # 'current_account' will be set in Account::Dashboard
  def _run_options(options)
    options['current_account'] = current_account if current_account
    options['current_admin'] = current_admin if current_admin
    options
  end

  def warn_if_no_trb
    # Enable this to help in the upgrade to Trailblazer
    if ENV['WARN_IF_NOT_TRB_OP'] && !@_run_called
      warn "#{self.class}##{params[:action]} needs upgrading to a TRB operation"
    end
  end

  # Show detailed error output to logged-in admins. Note that this only works
  # for 500 errors, not 404s. Also note that this method is only called when
  # config.consider_all_requests_local is false; when it's true (e.g.  in the
  # development environment), all requests show detailed exceptions anyway so
  # this method is irrelevant.
  def show_detailed_exceptions?
    !!current_admin
  end

  def auth_controller?
    false
  end
end
