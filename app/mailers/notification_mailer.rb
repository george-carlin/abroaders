class NotificationMailer < ApplicationMailer
  def notify_account_for_card_fee(account, card)
    @account = account
    @card = card
    mail(to: @account.email, subject: "Annual fee notification")
  end
end
