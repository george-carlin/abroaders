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

      unless current_account.has_any_recommendations?
        render("accounts/new_user_dashboard") && return
      end

      run(Account::Operation::Dashboard, {}, account: current_account)

      rec_timeout = cookies[:recommendation_timeout]

      render cell(Account::Cell::Dashboard, result, recommendation_timeout: rec_timeout)
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

  def new_log
  end

  def create_log
    Rails.logger.debug "DEBUG: #{params[:log]}"
    Rails.logger.info  "INFO: #{params[:log]}"
    Rails.logger.warn  "WARN: #{params[:log]}"
    Rails.logger.error "ERROR: #{params[:log]}"
    Rails.logger.fatal "FATAL: #{params[:log]}"
    respond_to { |f| f.js }
  end

  private

  # extend the method provided by trailblazer so that it sets
  # @collection from result['collection'] (if collection is provided)
  #
  # TODO remove me. If an operation has been run, our SOP is to pass the result
  # object directly to the cell. Maybe override `cell` this so it automatically
  # passes in the @_result object if @_result is present and no other argument
  # has been passed  to the cell.
  def run(*args)
    result = super
    @collection = @_result['collection']
    result
  end

  def warn_if_no_trb
    # Enable this to help in the upgrade to Trailblazer
    if ENV['WARN_IF_NOT_TRB_OP'] && !@_run_called
      warn "#{self.class}##{params[:action]} needs upgrading to a TRB operation"
    end
  end
end
