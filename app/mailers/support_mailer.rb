class SupportMailer < ApplicationMailer
  def support_message(opts = {})
    opts.symbolize_keys!
    account = Account.find(opts.fetch(:account_id))
    @message = opts.fetch(:message)
    mail(
      to: ENV['SUPPORT_EMAIL_ADDRESS'],
      from: "#{account.owner_first_name} <#{account.email}>",
      reply_to: account.email,
      subject: 'Recommendation Contact Form',
    )
  end
end
