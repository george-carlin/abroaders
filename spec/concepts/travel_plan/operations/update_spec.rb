require 'rails_helper'

RSpec.describe TravelPlan::Operations::Update do
  let(:lhr) { create(:airport, name: 'Heathrow', code: 'LHR') }
  let(:jfk) { create(:airport, name: 'JFK', code: 'JFK') }

  let(:next_year) { Date.today.year + 1 }
  let(:account) { create(:account) }
  let(:plan) do
    TravelPlan::Operations::Create.(
      {
        travel_plan: {
          depart_on: "05/18/#{next_year}",
          from: lhr.full_name,
          to:   jfk.full_name,
          type: 'single',
          no_of_passengers: 1,
        },
      },
      'account' => account,
    )['model']
  end
  let(:op) { described_class }

  example 'successful update' do
    result = op.(
      {
        id: plan.id,
        travel_plan: { # update all the things!
          from: jfk.full_name,
          to: lhr.full_name,
          type: 'return',
          no_of_passengers: 2,
          accepts_economy: true,
          accepts_premium_economy: true,
          accepts_business_class: true,
          accepts_first_class: true,
          depart_on: '05/08/2025',
          return_on: '08/05/2026',
          further_information: 'blah blah blah',
        },
      },
      'account' => account,
    )
    expect(result.success?).to be true

    plan.reload
    expect(plan.flights[0].from).to eq jfk
    expect(plan.flights[0].to).to eq lhr
    expect(plan.type).to eq 'return'
    expect(plan.no_of_passengers).to eq 2
    expect(plan.accepts_economy).to be true
    expect(plan.accepts_premium_economy).to be true
    expect(plan.accepts_business_class).to be true
    expect(plan.accepts_first_class).to be true
    expect(plan.depart_on).to eq Date.new(2025, 5, 8)
    expect(plan.return_on).to eq Date.new(2026, 8, 5)
    expect(plan.further_information).to eq 'blah blah blah'
  end

  example 'invalid update' do
    result = op.(
      {
        id: plan.id,
        travel_plan: { # return before depart:
          from: jfk.full_name,
          to: lhr.full_name,
          type: 'return',
          depart_on: '05/08/2025',
          return_on: '08/05/2024',
        },
      },
      'account' => account,
    )
    expect(result.success?).to be false
  end
end
