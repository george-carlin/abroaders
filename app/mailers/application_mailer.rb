class ApplicationMailer < ActionMailer::Base
  # At the time of writing, emails are sent through Sendgrid. AFAIK, if you
  # want to change the outbound email address, all you have to do is update
  # this ENV var. You can even update it to an address we don't actually own!
  # (The sender will appear, in GMail at least, as 'whatever@whatever.com via
  # sendgrid.me') Not sure why that works, but it does.
  default from: ENV['OUTBOUND_EMAIL_ADDRESS']
  layout 'mailer'

  helper ApplicationHelper

  # get access to the 'cell' method
  include ::Cell::RailsExtensions::ActionController
end
