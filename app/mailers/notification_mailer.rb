class NotificationMailer < ApplicationMailer
  def notify_account_for_card_fee(card)
    @card_holder = card.person
    @account = @card_holder.account
    @product = card.product

    mail(to: @account.email, subject: "Annual fee notification")
  end
end
