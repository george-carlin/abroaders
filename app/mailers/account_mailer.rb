class AccountMailer < ApplicationMailer

  def notify_admin_of_sign_up(account_id)
    @account = Account.find(account_id)
    mail(to: ENV["ERIKS_EMAIL"], subject: "New sign up at Abroaders app")
  end

end
