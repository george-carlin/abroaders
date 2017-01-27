require 'rails_helper'

RSpec.describe TravelPlan::Cell::AcceptableClasses do
  it 'returns a summary of the ACs' do
    def render(plan)
      described_class.(plan).()
    end

    plan = TravelPlan.new
    expect(render(plan)).to eq 'None given'
    plan = TravelPlan.new
    plan.accepts_economy = true
    expect(render(plan)).to eq 'E'
    plan.accepts_business_class = true
    expect(render(plan)).to eq 'E B'
    plan.accepts_first_class = '1st'
    expect(render(plan)).to eq 'E B 1st'
    plan.accepts_premium_economy = true
    expect(render(plan)).to eq 'E PE B 1st'
  end
end
