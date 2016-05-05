class NotificationsController < NonAdminController

  def show
    @notification = current_account.notifications.find(params[:id])
    @notification.update_attributes!(seen: true)
    # There's only one kind of notification atm. TODO
    redirect_to card_accounts_path
  end

end
