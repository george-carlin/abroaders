class UserInfosController < NonAdminController

  def new
    redirect_to root_path and return if current_user.info.present?
    @user_info = current_user.build_info
  end

  def create
    @user_info = current_user.build_info(user_info_params)
    if @user_info.save
      redirect_to card_survey_path
    else
      render "new"
    end
  end

  private

  def user_info_params
    params.require(:user_info).permit(
      :first_name, :middle_names, :last_name, :whatsapp, :imessage, :time_zone,
      :text_message, :phone_number, :credit_score, :business_spending,
      :will_apply_for_loan, :personal_spending, :has_business, :citizenship
    )
  end

end
