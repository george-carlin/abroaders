require "rails_helper"

describe "travel plans index page" do
  include AirportMacros
  subject { page }

  include_context "logged in"

  let(:tomorrow)   { Date.tomorrow }
  let(:next_week)  { 1.week.from_now }
  let(:next_month) { 1.month.from_now }

  let(:further_info) { "What the fuck ever" }

  before do
    @eu  = create(:region, name: "Europe")
    @uk  = create(:country, name: "UK",     parent: @eu)
    @fr  = create(:country, name: "France", parent: @eu)
    @lhr = create_airport("London Heathrow", :LHR, @uk)
    @lgw = create_airport("London Gatwick",  :LGW, @uk)
    @cdg = create_airport("Paris",           :CDG, @fr)

    @tp_single = account.travel_plans.create!(
      acceptable_classes:   [:economy, :premium_economy],
      departure_date_range: tomorrow..next_week,
      flights_attributes:   [ { from: @lgw, to: @cdg }],
      type:                 :single,
    )

    @tp_return = account.travel_plans.create!(
      acceptable_classes:   [:business_class, :first_class],
      departure_date_range: next_week..next_month,
      flights_attributes:   [ { from: @lhr, to: @cdg }],
      further_information:  further_info,
      type:                 :return,
    )

    # We're forggeting about 'multi' plans for the time being'
    # @tp_multi  = whatever

    visit travel_plans_path
  end

  it { is_expected.to have_title full_title("Travel Plans") }

  it "lists my travel plans" do
    expect(page).to have_selector "##{dom_id(@tp_single)}"
    expect(page).to have_selector "##{dom_id(@tp_return)}"
    # expect(page).to have_selector "##{dom_id(@tp_multi)}"
  end

  it "shows the earliest departue for each travel plan" do
    within_travel_plan(@tp_single) do
      expect(page).to have_content tomorrow.strftime("%D")
    end
    within_travel_plan(@tp_return) do
      expect(page).to have_content next_week.strftime("%D")
    end
  end

  it "shows any 'further information' notes" do
    within_travel_plan(@tp_return) do
      expect(page).to have_content further_info
    end
  end

  it "has a link to edit each plan" do
    expect(page).to have_link "Edit", href: edit_travel_plan_path(@tp_single)
    expect(page).to have_link "Edit", href: edit_travel_plan_path(@tp_return)
  end

  it "shows which classes of service are acceptable" do
    within_travel_plan(@tp_single) do
      expect(page).to have_content "E PE"
    end
    within_travel_plan(@tp_return) do
      expect(page).to have_content "B 1st"
    end
  end

  context "a multi travel plan" do
    before { skip "ignore multi plans for now" }
    it "lists the flights in the right order" do
      within_travel_plan(@tp_multi) do
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

  def within_travel_plan(plan)
    within "##{dom_id(plan)}" do
      yield
    end
  end

end
