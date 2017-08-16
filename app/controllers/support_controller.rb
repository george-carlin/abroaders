class SupportController < AuthenticatedUserController
  def support
    SupportMailer.support_message(
      account_id: current_account.id,
      message: params[:message],
    ).deliver_later
    flash[:success] = 'Message sent! Thanks'
    redirect_to cards_path
  end
end
