class HomeAirportsController < AuthenticatedUserController
  onboard :home_airports, with: [:survey, :save_survey]

  def survey
    @account = current_account
    # We need to run a Javascript snippet immediately after a user signs up -
    # but we need to make sure it doesn't get run again if they e.g. refresh
    # the page. This hacky solution will do for now.
    # (see also app/views/shared/third_party_scripts/_fb_tracking_pixel)
    # Use a randomly-generated cookie name to obfuscate what it's for if the
    # user looks at their cookies.
    @output_fb_signup_code = !cookies[:cbd50008665cc7269327074d2778d9a6]
    @survey = HomeAirports::Survey.new(@account)
  end

  def save_survey
    @account = current_account
    @survey = HomeAirports::Survey.new(@account)

    if @survey.validate(params[:home_airports_survey])
      @survey.save
      Account::Onboarder.new(current_account).add_home_airports!
      redirect_to onboarding_survey_path
    else
      # It's impossible to submit an invalid form through the web interface
      raise 'this should never happen!'
    end
  end

  def index
    render cell(HomeAirports::Cell::Index, current_account.home_airports)
  end

  def edit
    @account = current_account
    @survey = HomeAirports::Survey.new(@account)
    render 'survey'
  end

  # This is a quick solution to the problem of how users can update their home
  # airport after the onboarding survey - I've just taken the existing survey
  # logic and re-used it, with a couple of conditionals thrown in to make the
  # two pages function very slightly differently from each other.
  #
  # This isn't great design, but it's not a very important feature and we
  # needed something built quickly.
  def overwrite
    @account = current_account
    @survey = HomeAirports::Survey.new(@account)

    if @survey.validate(params[:home_airports_survey])
      @survey.save
      redirect_to onboarding_survey_path
    else
      # It's impossible to submit an invalid form through the web interface
      raise 'this should never happen!'
    end
  end

  private

  def survey_params
    survey_params = params.require(:home_airports_survey).permit(airport_ids: [])
    survey_params.merge(account: @account)
  end
end
