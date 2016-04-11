class SurveyController < NonAdminController

  def new_readiness
    @survey = ReadinessSurvey.new(current_account)
    if has_companion?
      @mp_name = Name.new(current_main_passenger.first_name)
      @co_name = Name.new(current_companion.first_name)
    else
      @mp_name = Name.you
    end
  end

  def create_readiness
    @survey = ReadinessSurvey.new(current_account)
    @survey.update_attributes!(readiness_survey_params)
    redirect_to root_path
  end

  private

  def load_name(passenger_type)
    if passenger_type == "main"
      if has_companion?
        Name.new(current_main_passenger.first_name)
      else
        Name.you
      end
    else
      Name.new(current_companion.first_name)
    end
  end

  def readiness_survey_params
    params.require(:readiness_survey).permit(
      :main_passenger_ready, :main_passenger_unreadiness_reason,
      :companion_ready,      :companion_unreadiness_reason
    )
  end

end
