require "rails_helper"

describe "travel plans page" do
  include AirportMacros
  subject { page }

  include_context "logged in"

  before do
    @eu  = create(:region, name: "Europe")
    @lhr = create_airport("London Heathrow", :LHR, @eu)
    @lgw = create_airport("London Gatwick",  :LGW, @eu)
    @cdg = create_airport("Paris",           :CDG, @eu)

    def create_travel_plan(type, flights)
      user.travel_plans.create!(
        departure_date_range: Date.today..Date.tomorrow,
        flights_attributes:   flights,
        type:                 type
      )
    end
    @tp_single = create_travel_plan(:single, [ { from: @lhr, to: @cdg }])
    @tp_return = create_travel_plan(:return, [ { from: @lgw, to: @cdg }])
    @tp_multi  = create_travel_plan(
      :multi,
      [
        { from: @cdg, to: @lhr, position: 1 },
        { from: @lgw, to: @cdg, position: 0 },
        { from: @lhr, to: @cdg, position: 2 }
      ]
    )
    visit travel_plans_path
  end

  it "lists my travel plans" do
    is_expected.to have_selector "##{dom_id(@tp_single)}"
    is_expected.to have_selector "##{dom_id(@tp_return)}"
    is_expected.to have_selector "##{dom_id(@tp_multi)}"
  end

  context "a multi travel plan" do
    it "lists the flights in the right order" do
      within "##{dom_id(@tp_multi)}" do
        dom_flights = all(".flight")
        flight_0 = @tp_multi.flights.find_by!(position: 0)
        flight_1 = @tp_multi.flights.find_by!(position: 1)
        flight_2 = @tp_multi.flights.find_by!(position: 2)
        expect(dom_flights[0][:id]).to eq "flight_#{flight_0.id}"
        expect(dom_flights[1][:id]).to eq "flight_#{flight_1.id}"
        expect(dom_flights[2][:id]).to eq "flight_#{flight_2.id}"
      end
    end
  end

end
