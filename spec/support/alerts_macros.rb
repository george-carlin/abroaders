module AlertsMacros

  def error_message
    ".alert.alert-danger"
  end

  def info_message
    ".alert.alert-info"
  end

  def success_message
    ".alert.alert-success"
  end

  def have_error_message(text=nil, opts={})
    have_selector error_message, opts.merge(text: text)
  end

  def have_info_message(text=nil, opts={})
    have_selector info_message, opts.merge(text: text)
  end

  def have_success_message(text=nil, opts={})
    have_selector success_message, opts.merge(text: text)
  end

end
