Warden::Manager.after_authentication do |_record, warden, _options|
  clean_up_for_winning_strategy = !warden.winning_strategy.respond_to?(:clean_up_csrf?) ||
                                  warden.winning_strategy.clean_up_csrf?
  if clean_up_for_winning_strategy
    warden.request.session.try(:delete, :_csrf_token)
  end
end
