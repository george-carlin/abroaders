require "rails_helper"

describe HomeAirportsSurvey, type: :model do

  it { is_expected.to validate_presence_of :account }
  it { is_expected.to validate_presence_of :airport_ids }

  example "saving" do
    @airport_0 = create(:airport)
    @airport_1 = create(:airport)
    @airport_2 = create(:airport)

    @account = create(:account)
    @survey = HomeAirportsSurvey.new(
      account:     @account,
      airport_ids: [@airport_1, @airport_2],
    )

    expect(@account.onboarding_state).to eq "home_airports"
    expect { @survey.save! }.to change{@account.home_airports.count}.by(2)
    expect(@account.home_airports).to match_array [@airport_1, @airport_2]
    expect(@account.onboarding_state).to eq "travel_plan"
  end

end
