require "rails_helper"

RSpec.describe "travel plans index page" do
  subject { page }

  include_context "logged in"

  let(:create_tps!) { nil }

  example 'when I have no travel plans' do
    visit travel_plans_path
    expect(page).to have_content "You haven't added any travel plans yet."
  end

  example 'when I have travel plans' do
    tps = Array.new(2) { create_travel_plan(account: account) }
    visit travel_plans_path

    expect(page).to have_no_content 'No travel plans!'
    expect(page).to have_selector "#travel_plan_#{tps[0].id}"
    expect(page).to have_selector "#travel_plan_#{tps[1].id}"

    # the details about what is displayed for each plan is tested
    # in the spec for TravelPlan::Cell::Summary
  end
end
