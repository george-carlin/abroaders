require 'rails_helper'

RSpec.describe TravelPlan::Operations::Update do
  let(:lhr) { create(:airport, name: 'Heathrow', code: 'LHR') }
  let(:jfk) { create(:airport, name: 'JFK', code: 'JFK') }
  let(:lhr_s) { "#{lhr.name} (#{lhr.code})" }
  let(:jfk_s) { "#{jfk.name} (#{jfk.code})" }

  let(:next_year) { Date.today.year + 1 }
  let(:account) { create(:account) }
  let(:plan) do
    TravelPlan::Operations::Create.(
      {
        travel_plan: {
          depart_on: "05/18/#{next_year}",
          from: lhr_s,
          to:   jfk_s,
          type: 'single',
          no_of_passengers: 1,
        },
      },
      'current_account' => account,
    )['model']
  end
  let(:op) { described_class }

  example 'successful update' do
    result = op.(
      {
        id: plan.id,
        travel_plan: { # update all the things!
          from: jfk_s,
          to: lhr_s,
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
      'current_account' => account,
    )
    expect(result.success?).to be true

    tp = account.travel_plans.last
    expect(tp.flights[0].from).to eq lhr
    expect(tp.flights[0].to).to eq jfk
    expect(tp.type).to eq 'single'
    expect(tp.no_of_passengers).to eq 2
    expect(tp.accepts_economy).to be true
    expect(tp.accepts_premium_economy).to be true
    expect(tp.accepts_business_class).to be true
    expect(tp.accepts_first_class).to be true
    expect(tp.depart_on).to eq Date.new(2025, 5, 8)
    expect(tp.return_on).to eq Date.new(2026, 8, 5)
    expect(tp.further_information).to eq 'blah blah blah'
  end

  example 'invalid update' do
    result = op.(
      {
        id: plan.id,
        travel_plan: { # return before depart:
          from: jfk_s,
          to: lhr_s,
          type: 'return',
          depart_on: '05/08/2025',
          return_on: '08/05/2024',
        },
      },
      'current_account' => account,
    )
    expect(result.success?).to be false
  end
end
