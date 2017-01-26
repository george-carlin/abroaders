require "rails_helper"

RSpec.describe "travel plans index page" do
  subject { page }

  include_context "logged in"

  before do
    @tps = create_list(:travel_plan, 2, account: account)
    visit travel_plans_path
  end

  it { is_expected.to have_title full_title("Travel Plans") }

  it 'lists the travel plans' do
    expect(page).to have_selector "##{dom_id(@tps[0])}"
    expect(page).to have_selector "##{dom_id(@tps[1])}"
  end

  # TODO display something smart when there are no TPs
end
