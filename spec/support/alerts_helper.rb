module AlertsHelper

  def error_message
    ".alert.alert-danger"
  end

  def info_message
    ".alert.alert-info"
  end

  def success_message
    ".alert.alert-success"
  end

  def have_error_message(opts={})
    have_selector error_message, opts
  end

  def have_info_message(opts={})
    have_selector info_message, opts
  end

  def have_success_message(opts={})
    have_selector success_message, opts
  end

end
