require 'cells_helper'

RSpec.describe TravelPlan::Cell::AcceptableClasses do
  it 'returns a summary of the ACs' do
    plan = TravelPlan.new
    expect(show(plan).raw).to eq 'None given'
    plan = TravelPlan.new
    plan.accepts_economy = true
    expect(show(plan).raw).to eq 'E'
    plan.accepts_business_class = true
    expect(show(plan).raw).to eq 'E B'
    plan.accepts_first_class = '1st'
    expect(show(plan).raw).to eq 'E B 1st'
    plan.accepts_premium_economy = true
    expect(show(plan).raw).to eq 'E PE B 1st'
  end
end
