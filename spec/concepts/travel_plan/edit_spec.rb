require 'rails_helper'

RSpec.describe TravelPlan::Edit do
  let(:op) { described_class }

  let(:lhr) { create(:airport, name: 'Heathrow', code: 'LHR') }
  let(:jfk) { create(:airport, name: 'JFK', code: 'JFK') }

  let(:account) { create(:account, :onboarded) }

  let(:plan) do
    create_travel_plan(
      account: account,
      depart_on: "05/18/#{Date.today.year + 1}",
      from: lhr,
      no_of_passengers: 1,
      to: jfk,
      type: 'one_way',
    )
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
