require 'rails_helper'

RSpec.describe TravelPlan::Destroy do
  let(:travel_plan) { create_travel_plan }
  let(:account) { travel_plan.account }
  let(:op) { described_class }

  it 'destroys the travel plan' do
    result = op.({ id: travel_plan.id }, 'current_account' => account)
    expect(result.success?).to be true
    expect(TravelPlan.find_by(id: travel_plan.id)).to be nil
  end

  it "can't destroy someone else's travel plan" do
    expect do
      op.({ id: travel_plan.id }, 'current_account' => create_account)
    end.to raise_error ActiveRecord::RecordNotFound
  end
end
