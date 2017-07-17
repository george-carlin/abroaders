module Auth::Controllers::SignInOut
  def sign_in(scope, resource, options = {})
    expire_data_after_sign_in!

    if options[:bypass]
      warden.session_serializer.store(resource, scope)
    elsif warden.user(scope) == resource # && !options.delete(:force)
      # Do nothing. User already signed in and we are not forcing it.
      true
    else
      warden.set_user(resource, scope: scope) # options.merge!(scope: scope))
    end
  end

  def sign_out(scope)
    warden.logout(scope)
  end

  def sign_out_all_scopes(lock = true)
    users = Devise.mappings.each_value do |m|
      warden.user(scope: m.name, run_callbacks: false)
    end

    warden.logout
    expire_data_after_sign_out!
    warden.clear_strategies_cache!
    warden.lock! if lock

    users.any?
  end

  private

  def all_signed_out?
    users = Devise.mappings.each_value do |m|
      warden.user(scope: m.name, run_callbacks: false)
    end
    users.all?(&:blank?)
  end

  def expire_data_after_sign_in!
    # session.keys will return an empty array if the session is not yet loaded.
    # This is a bug in both Rack and Rails.
    # A call to #empty? forces the session to be loaded.
    session.empty?
    session.keys.grep(/^devise\./).each { |k| session.delete(k) }
  end
  alias expire_data_after_sign_out! expire_data_after_sign_in!

  # Helper for use in before_actions where no authentication is required.
  #
  # Example:
  #   before_action :require_no_authentication, only: :new
  def require_no_authentication(scope)
    if warden.authenticated?(scope) && warden.user(scope)
      flash[:alert] = I18n.t("devise.failure.already_authenticated")
      redirect_to root_path
    end
  end

  # Check if there is no signed in user before doing the sign out.
  #
  # If there is no signed in user, it will set the flash message and redirect
  # to the after_sign_out path.
  def verify_signed_out_user
    if all_signed_out?
      flash[:notice] = I18n.t('devise.sessions.already_signed_out')
      redirect_to root_path
    end
  end
end
