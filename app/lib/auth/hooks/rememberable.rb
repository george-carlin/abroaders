Warden::Manager.after_set_user except: :fetch do |record, warden, options|
  scope = options[:scope]
  if record.respond_to?(:remember_me) && options[:store] != false &&
     record.remember_me && warden.authenticated?(scope)
    Auth::Hooks::Proxy.new(warden).remember_me(record)
  end
end