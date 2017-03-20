class ApplicationController < ActionController::Base
  include Onboarding
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_action :warn_if_no_trb

  include I18nWithErrorRaising

  def dashboard
    if current_admin
      render "admin_area/dashboard"
    elsif current_account
      redirect_if_not_onboarded! && return

      run Account::Operation::Dashboard
      render cell(Account::Cell::Dashboard, result)
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

  private

  # Pass these options by default into Trailblazer operations when calling
  # them with 'run'.
  #
  # This needs to live here rather than AuthenticatedUserController so that
  # 'account' will be set in Account::Operation::Dashboard
  def _run_options(options)
    options['account'] = current_account if current_account
    options
  end

  def warn_if_no_trb
    # Enable this to help in the upgrade to Trailblazer
    if ENV['WARN_IF_NOT_TRB_OP'] && !@_run_called
      warn "#{self.class}##{params[:action]} needs upgrading to a TRB operation"
    end
  end
end
