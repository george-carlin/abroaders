require "rails_helper"

describe EditTravelPlanForm, type: :model do
  skip "need to figure out a better approach for 'edit' form objects" do
    let(:travel_plan) { create(:travel_plan, :return) }
    let(:account) { Account.new }
    let(:form)    { described_class.new(account: account, travel_plan: travel_plan) }
    subject { form }
  end
end
