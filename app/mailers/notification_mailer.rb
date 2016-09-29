class NotificationMailer < ApplicationMailer
  def notify_account_for_card_fee(card_account)
    @card_holder = card_account.person
    @account = @card_holder.account
    @card = card_account.card

    mail(to: @account.email, subject: "Annual fee notification")
  end
end
