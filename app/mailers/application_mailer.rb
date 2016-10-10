class ApplicationMailer < ActionMailer::Base
  default from: ENV["OUTBOUND_EMAIL_ADDRESS"]
  layout 'mailer'

  helper ApplicationHelper
end
