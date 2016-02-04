require "rails_helper"

describe "new travel plans page" do

  subject { page }

  include_context "logged in"

  before(:all) do
    @destinations = [
      @lhr = create(:airport, name: "London Heathrow",     code: "LHR"),
      @lgw = create(:airport, name: "London Gatwick",      code: "LGW"),
      @yyz = create(:airport, name: "Toronto Pearson",     code: "YYZ"),
      @sgn = create(:airport, name: "Ho Chi Minh City",    code: "SGN"),
      @jfk = create(:airport, name: "New York J.F.K.",     code: "JFK"),
      @lga = create(:airport, name: "New York La Guardia", code: "LGA"),
      @ltn = create(:airport, name: "London Luton",        code: "LTN")
    ]
  end
  after(:all) { Destination.delete_all }

  before do
    visit new_travel_plan_path
  end

  it "has a selector to choose the travel plan type" do
    is_expected.to have_field :travel_plan_type_single
    is_expected.to have_field :travel_plan_type_return
    is_expected.to have_field :travel_plan_type_multi
  end

  specify "'return' type is selected by default" do
    radio = find("#travel_plan_type_return")
    expect(radio).to be_checked
  end

  it "has inputs for journey origin and destination" do
    is_expected.to have_field leg_field(0, :from)
    is_expected.to have_field leg_field(0, :to)
  end

  it "has an input for the departure date range" do
    is_expected.to have_field :travel_plan_departure_date_range
  end

  describe "searching for an airport in the 'from' input", js: true do
    before do
      fill_in leg_field(0, :from), with: "lond"
    end

    it "populates the dropdown with suggestions" do
      css = ".typeahead.dropdown-menu"
      [@lhr, @lgw, @ltn].each do |a|
        is_expected.to have_selector css, text: "#{a.name} (#{a.code})"
      end
      [@yyz, @sgn, @jfk, @lga].each do |a|
        is_expected.not_to have_selector css, text: "#{a.name} (#{a.code})"
      end
    end

    describe "and choosing a suggestion" do
      it "fills the input with the chosen suggestion"
    end
  end

  describe "searching for an airport in the 'to' input", js: true do
    it "populates the dropdown with suggestions"

    describe "and choosing a suggestion" do
      it "fills the input with the chosen suggestion"
    end
  end

  describe "selecting a departure date"
  describe "selecting a return date"

  describe "filling in the form" do
    describe "with valid details for a 'return' travel plan" do
      describe "and clicking 'save'" do
        it "creates a return travel plan"

        pending "TODO: what does it show me next?"
      end
    end

    describe "with invalid details for a 'return' travel plan" do
      pending
    end
  end

  describe "clicking 'single'" do
    it "disables the 'return date' input"

    describe "and clicking 'return' again" do
      it "reenables the 'return date' input"
    end

    describe "and filling in the form" do
      describe "with valid details for a single travel plan" do
        describe "and clicking 'save'" do
          it "creates a single travel plan"

          pending "TODO: what does it show me next?"
        end
      end

      describe "with invalid details for a single travel plan" do
        describe "and clicking 'save'" do
          pending
        end
      end
    end
  end

  describe "clicking 'multi'" do
    it "shows the 'add/remove leg' buttons"

    describe "the first 'remove leg' button" do
      it "is initially disabled"
    end

    describe "and clicking 'add leg'" do
      it "adds a form for a second travel leg"
      it "enables the 'remove leg' buttons"

      describe "and clicking 'remove leg' again" do
        it "removes the travel leg form"
        it "disables the 'remove leg' buttons"
      end
    end

    describe "and adding the maximum number of travel legs" do
      it "disables the 'add leg' buttons"

      describe "and removing a leg again" do
        it "reenables the 'add leg' buttons"
      end
    end

    describe "and submitting the form" do
      describe "with valid data"
      describe "with invalid data"
    end
  end

  def leg_field(position, attribute)
    :"travel_plan_legs_attributes_#{position}_#{attribute}"
  end

end
