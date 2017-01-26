require 'rails_helper'

describe TravelPlan::Operations::Create do
  let(:account) { create(:account) }
  let(:op) { described_class }

  let(:lhr) { create(:airport, name: 'Heathrow', code: 'LHR') }
  let(:jfk) { create(:airport, name: 'JFK', code: 'JFK') }
  let(:lhr_s) { "#{lhr.name} (#{lhr.code})" }
  let(:jfk_s) { "#{jfk.name} (#{jfk.code})" }

  example 'creating a one-way travel plan' do
    result = op.(
      {
        travel_plan: {
          from: lhr_s,
          to: jfk_s,
          type: 'single',
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
    expect(tp.type).to eq 'single'
    expect(tp.no_of_passengers).to eq 2
    expect(tp.accepts_economy).to be true
    expect(tp.accepts_premium_economy).to be true
    expect(tp.accepts_business_class).to be true
    expect(tp.accepts_first_class).to be true
    expect(tp.depart_on).to eq Date.new(2025, 5, 8)
    expect(tp.return_on).to be_nil
    expect(tp.further_information).to eq 'blah blah blah'
  end

  example 'creating a return travel plan' do
    result = op.(
      {
        travel_plan: {
          from: jfk_s,
          to: lhr_s,
          type: 'return',
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
    expect(tp.type).to eq 'return'
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
          from: jfk_s,
          to: lhr_s,
          type: 'single',
          depart_on: '05/03/2015', # in the past
        },
      },
      'current_account' => account,
    )
    expect(result.success?).to be false
  end
end
