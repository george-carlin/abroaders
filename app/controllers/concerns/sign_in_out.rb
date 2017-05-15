module SignInOut
  WARDEN_SCOPES = %i[account admin]

  def sign_in(resource_or_scope, *args)
    options  = args.extract_options!
    scope    = Devise::Mapping.find_scope!(resource_or_scope)
    resource = args.last || resource_or_scope

    expire_data_after_sign_in!

    if options[:bypass]
      warden.session_serializer.store(resource, scope)
    elsif warden.user(scope) == resource && !options.delete(:force)
      # Do nothing. User already signed in and we are not forcing it.
      true
    else
      warden.set_user(resource, options.merge!(scope: scope))
    end
  end

  def sign_out_all_scopes(lock = true)
    users = WARDEN_SCOPES.each { |s| warden.user(scope: s, run_callbacks: false) }

    warden.logout
    expire_data_after_sign_out!
    warden.clear_strategies_cache!
    warden.lock! if lock

    users.any?
  end

  private

  def all_signed_out?
    users = WARDEN_SCOPES.each { |s| warden.user(scope: s, run_callbacks: false) }

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
end
