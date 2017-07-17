# devise loads this - looks like it needs to monkey-patch Warden to get
# access to cookies within strategies (and possibly elsewhere)
module Warden::Mixins::Common
  def request
    @request ||= ActionDispatch::Request.new(env)
  end

  def reset_session!
    request.reset_session
  end

  def cookies
    request.cookie_jar
  end
end
