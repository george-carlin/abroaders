require 'rails_helper'

RSpec.describe TravelPlan::Operation::Destroy do
  let(:travel_plan) { create(:travel_plan) }
  let(:account) { travel_plan.account }
  let(:op) { described_class }

  it 'destroys the travel plan' do
    result = op.({ id: travel_plan.id }, 'account' => account)
    expect(result.success?).to be true
    expect(TravelPlan.find_by(id: travel_plan.id)).to be nil
  end

  it "can't destroy someone else's travel plan" do
    other_account = create(:account)
    expect do
      op.({ id: travel_plan.id }, 'account' => other_account)
    end.to raise_error ActiveRecord::RecordNotFound
  end
end
