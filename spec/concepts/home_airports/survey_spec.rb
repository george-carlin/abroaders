require 'rails_helper'

RSpec.describe HomeAirports::Survey do
  let(:airport_0) { create(:airport) }
  let(:airport_1) { create(:airport) }
  let(:airport_2) { create(:airport) }

  let(:account) do
    run!(
      Registration::Operation::Create,
      account: {
        email: 'a@b.com',
        first_name: 'George',
        password: 'abroaders123',
        password_confirmation: 'abroaders123',
      },
    )['model']
  end

  example 'account has no home airports' do
    survey = HomeAirports::Survey.new(account)

    expect(survey.validate(home_airports: [airport_1.id, airport_2.id])).to be true

    expect { survey.save }.to change { account.home_airports.count }.by(2)
    expect(account.home_airports).to match_array [airport_1, airport_2]
  end

  example 'overwriting existing home airports' do
    survey = HomeAirports::Survey.new(account)
    survey.validate(home_airports: [airport_0.id, airport_2.id])
    survey.save

    # and again, with different airports:
    survey = HomeAirports::Survey.new(account)
    expect(survey.validate(home_airports: [airport_0.id, airport_2.id])).to be true

    survey.save

    expect(account.reload.home_airports).to match_array([airport_0, airport_2])
  end
end
