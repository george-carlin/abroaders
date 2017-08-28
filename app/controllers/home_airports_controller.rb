class HomeAirportsController < AuthenticatedUserController
  onboard :home_airports, with: [:survey, :save_survey]

  def survey
    form = HomeAirports::Survey.new(current_account)
    render cell(HomeAirports::Cell::Survey, current_account, form: form)
  end

  def save_survey
    form = HomeAirports::Survey.new(current_account)

    if form.validate(params[:home_airports_survey])
      form.save
      Account::Onboarder.new(current_account).add_home_airports!
      redirect_to onboarding_survey_path
    else # it's impossible to submit an invalid form through the web interface
      raise 'this should never happen!'
    end
  end

  def index
    render cell(HomeAirports::Cell::Index, current_account.home_airports)
  end

  def edit
    form = HomeAirports::Survey.new(current_account)
    render cell(HomeAirports::Cell::Survey, current_account, form: form, editing: true)
  end

  # This is a quick solution to the problem of how users can update their home
  # airport after the onboarding survey - I've just taken the existing survey
  # logic and re-used it, with a couple of conditionals thrown in to make the
  # two pages function very slightly differently from each other.
  #
  # This isn't great design, but it's not a very important feature and we
  # needed something built quickly.
  def overwrite
    form = HomeAirports::Survey.new(current_account)

    if form.validate(params[:home_airports_survey])
      form.save
      redirect_to travel_plans_path
    else # it's impossible to submit an invalid form through the web interface
      raise 'this should never happen!'
    end
  end
end
