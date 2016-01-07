class ContactInfosController < AuthenticatedController

  def new
    redirect_to root_path and return if current_user.contact_info.present?
    @contact_info = current_user.build_contact_info
  end

  def create
    @contact_info = current_user.build_contact_info(contact_info_params)
    if @contact_info.save
      redirect_to root_path
    else
      render "new"
    end
  end

  private

  def contact_info_params
    params.require(:contact_info).permit(
      :first_name, :middle_names, :last_name, :whatsapp, :imessage,
      :text_message, :phone_number, :time_zone
    )
  end

end
