require 'rails_helper'

RSpec.describe TravelPlan::Edit do
  let(:op) { described_class }

  let(:lhr) { create(:airport, name: 'Heathrow', code: 'LHR') }
  let(:jfk) { create(:airport, name: 'JFK', code: 'JFK') }
  let(:lhr_s) { "#{lhr.name} (#{lhr.code})" }
  let(:jfk_s) { "#{jfk.name} (#{jfk.code})" }

  let(:account) { create(:account) }

  let(:plan) do
    TravelPlan::Create.(
      {
        travel_plan: {
          depart_on: "05/18/#{Date.today.year + 1}",
          from: lhr_s,
          to:   jfk_s,
          type: 'one_way',
          no_of_passengers: 1,
        },
      },
      'account' => account,
    )['model']
  end

  it 'only finds my travel plans' do
    expect(op.({ id: plan.id }, 'account' => account)['model']).to eq plan

    expect do
      op.({ id: plan.id }, 'account' => create(:account)).success?
    end.to raise_error ActiveRecord::RecordNotFound
  end

  it 'raises an error for old-style travel plans' do
    plan.flights[0].update!(from: lhr.country, to: jfk.country)
    expect do
      op.({ id: plan.id }, 'account' => account).success?
    end.to raise_error RuntimeError
  end
end
