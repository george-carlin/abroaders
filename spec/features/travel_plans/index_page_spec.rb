require "rails_helper"

RSpec.describe "travel plans index page" do
  subject { page }

  include_context "logged in"

  let(:tomorrow)   { Time.zone.tomorrow }
  let(:next_week)  { 1.week.from_now }
  let(:next_month) { 1.month.from_now }

  let(:further_info) { "What the fuck ever" }

  before do
    def create_airport(name, code, parent = nil)
      create(:airport, name: name, code: code, parent: parent)
    end

    @eu  = create(:region, name: "Europe")
    @uk  = create(:country, name: "UK",     parent: @eu)
    @fr  = create(:country, name: "France", parent: @eu)
    @lon = create(:city,    parent: @uk)
    @par = create(:city,    parent: @fr)
    @lhr = create_airport("London Heathrow", :LHR, @lon)
    @lgw = create_airport("London Gatwick",  :LGW, @lon)
    @cdg = create_airport("Paris",           :CDG, @par)

    @tp_single = account.travel_plans.create!(
      accepts_economy:         true,
      accepts_premium_economy: true,
      depart_on:            tomorrow,
      return_on:            next_week,
      flights_attributes:   [{ from: @lgw, to: @cdg }],
      type:                 :single,
    )

    @tp_return = account.travel_plans.create!(
      accepts_business_class: true,
      accepts_first_class:    true,
      depart_on:            next_week,
      return_on:            next_month,
      flights_attributes:   [{ from: @lhr, to: @cdg }],
      further_information:  further_info,
      type:                 :return,
    )

    visit travel_plans_path
  end

  it { is_expected.to have_title full_title("Travel Plans") }

  it "lists my travel plans" do
    expect(page).to have_selector "##{dom_id(@tp_single)}"
    expect(page).to have_selector "##{dom_id(@tp_return)}"
  end
end
