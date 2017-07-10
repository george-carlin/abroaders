require 'rails_helper'

RSpec.describe TravelPlan::Create do
  let(:account) { create_account }
  let(:op) { described_class }

  let(:lhr) { create(:airport, name: 'Heathrow', code: 'LHR') }
  let(:jfk) { create(:airport, name: 'JFK', code: 'JFK') }

  example 'creating a one-way travel plan' do
    result = op.(
      {
        travel_plan: {
          from: lhr.full_name,
          to: jfk.full_name,
          type: 'one_way',
          no_of_passengers: 2,
          accepts_economy: true,
          accepts_premium_economy: true,
          accepts_business_class: true,
          accepts_first_class: true,
          depart_on: '05/08/2025',
          further_information: 'blah blah blah',
        },
      },
      'current_account' => account,
    )
    expect(result.success?).to be true

    tp = account.travel_plans.last
    expect(tp.flights[0].from).to eq lhr
    expect(tp.flights[0].to).to eq jfk
    expect(tp.type).to eq 'one_way'
    expect(tp.no_of_passengers).to eq 2
    expect(tp.accepts_economy).to be true
    expect(tp.accepts_premium_economy).to be true
    expect(tp.accepts_business_class).to be true
    expect(tp.accepts_first_class).to be true
    expect(tp.depart_on).to eq Date.new(2025, 5, 8)
    expect(tp.return_on).to be_nil
    expect(tp.further_information).to eq 'blah blah blah'
  end

  example 'creating a round-trip travel plan' do
    result = op.(
      {
        travel_plan: {
          from: jfk.full_name,
          to: lhr.full_name,
          type: 'round_trip',
          no_of_passengers: 4,
          depart_on: '05/08/2020',
          return_on: '12/03/2023',
        },
      },
      'current_account' => account,
    )
    expect(result.success?).to be true

    tp = account.travel_plans.last
    expect(tp.flights[0].from).to eq jfk
    expect(tp.flights[0].to).to eq lhr
    expect(tp.type).to eq 'round_trip'
    expect(tp.no_of_passengers).to eq 4
    expect(tp.accepts_economy).to be false
    expect(tp.accepts_premium_economy).to be false
    expect(tp.accepts_business_class).to be false
    expect(tp.accepts_first_class).to be false
    expect(tp.depart_on).to eq Date.new(2020, 5, 8)
    expect(tp.return_on).to eq Date.new(2023, 12, 3)
    expect(tp.further_information).to be nil
  end

  example 'invalid save' do
    result = op.(
      {
        travel_plan: {
          from: jfk.full_name,
          to: lhr.full_name,
          type: 'one_way',
          depart_on: '05/03/2015', # in the past
        },
      },
      'current_account' => account,
    )
    expect(result.success?).to be false
  end

  describe TravelPlan::Onboard do
    let(:op) { TravelPlan::Onboard }
    let(:account) { create_account(onboarding_state: :travel_plan) }

    example 'valid save' do
      result = op.(
        {
          travel_plan: {
            from: jfk.full_name,
            to: lhr.full_name,
            type: 'round_trip',
            no_of_passengers: 1,
            depart_on: '05/08/2020',
            return_on: '12/03/2023',
          },
        },
        'current_account' => account,
      )
      expect(result.success?).to be true
      expect(account.reload.onboarding_state).to eq 'account_type'
    end

    example 'invalid save' do
      result = op.(
        { travel_plan: {} },
        'current_account' => account,
      )
      expect(result.success?).to be false
      expect(account.reload.onboarding_state).to eq 'travel_plan'
    end
  end
end
