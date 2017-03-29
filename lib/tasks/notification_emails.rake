namespace :ab do
  desc "A notification email to remind a user about the annual fee"
  task card_fee_notification_email: :environment do
    CardAccount.includes(:card, person: :account).open.unclosed.find_each do |card_account|
      card_account_date = card_account.opened_on - 15.days
      current_date = Date.current

      # don't send email for current year
      if card_account_date.strftime("%Y") != current_date.strftime("%Y")
        # send email if current day and month is equal to 15 days before card account opened. ex: if "15 Sep" == "15 Sep"
        send_email = card_account_date.strftime("%d %b") == current_date.strftime("%d %b")
      else
        send_email = false
      end

      NotificationMailer.notify_account_for_card_fee(card_account).deliver_now if send_email
    end
  end
end
