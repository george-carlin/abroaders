require "rails_helper"

RSpec.describe "travel plans index page" do
  subject { page }

  include_context "logged in"

  before do
    create_tps!
    visit travel_plans_path
  end

  let(:create_tps!) { nil }

  it { is_expected.to have_title full_title('Travel Plans') }

  example 'when I have no travel plans' do
    expect(page).to have_content "You haven't added any travel plans yet."
  end

  context 'when I have travel plans' do
    let(:create_tps!) { @tps = create_list(:travel_plan, 2, account: account) }

    it 'lists them' do
      expect(page).to have_no_content 'No travel plans!'
      expect(page).to have_selector "##{dom_id(@tps[0])}"
      expect(page).to have_selector "##{dom_id(@tps[1])}"
    end

    # the details about what is displayed for each plan is tested
    # in the spec for TravelPlan::Cell::Summary
  end
end
