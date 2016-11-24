class NotificationsController < AuthenticatedUserController
  def show
    @notification = current_account.notifications.find(params[:id])
    @notification.update_attributes!(seen: true)
    # There's only one kind of notification atm.
    redirect_to cards_path
  end
end
