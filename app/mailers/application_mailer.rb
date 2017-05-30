class ApplicationMailer < ActionMailer::Base
  default from: ENV["OUTBOUND_EMAIL_ADDRESS"]
  layout 'mailer'

  helper ApplicationHelper

  # get access to the 'cell' method
  include ::Cell::RailsExtensions::ActionController
end
