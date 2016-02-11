require "rails_helper"

# Page is rendered with React.js; all tests must activate Javascript
describe "new travel plans page", js: true do

  subject { page }

  include_context "logged in"

  before do
    @destinations = [
      @lhr = create(:airport, name: "London Heathrow",     code: "LHR"),
      @lgw = create(:airport, name: "London Gatwick",      code: "LGW"),
      @yyz = create(:airport, name: "Toronto Pearson",     code: "YYZ"),
      @sgn = create(:airport, name: "Ho Chi Minh City",    code: "SGN"),
      @jfk = create(:airport, name: "New York J.F.K.",     code: "JFK"),
      @lga = create(:airport, name: "New York La Guardia", code: "LGA"),
      @ltn = create(:airport, name: "London Luton",        code: "LTN")
    ]
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

  specify "the 'add/remove flight' buttons are initially hidden" do
    is_expected.not_to have_selector add_flight_btn
    is_expected.not_to have_selector remove_flight_btn
  end

  it "has inputs for journey origin and destination" do
    is_expected.to have_field flight_field(0, :from)
    is_expected.to have_field flight_field(0, :to)
  end

  it "has an input for the departure date range" do
    is_expected.to have_field :travel_plan_departure_date_range
  end

  describe "the 'number of passengers' input" do
    it "says '1' by default" do
      expect(find("#travel_plan_no_of_passengers").value).to eq "1"
    end
  end

  %i[from to].each do |place|
    describe "searching for an airport in the '#{place}' input" do
      before do
        fill_in flight_field(0, place), with: "lond"
        wait_for_ajax
      end

      let(:option) { ".typeahead.dropdown-menu > li > a" }

      it "populates the dropdown with suggestions" do
        [@lhr, @lgw, @ltn].each do |a|
          is_expected.to have_selector option, text: "#{a.name} (#{a.code})"
        end
        [@yyz, @sgn, @jfk, @lga].each do |a|
          is_expected.not_to have_selector option, text: "#{a.name} (#{a.code})"
        end
      end

      describe "and choosing a suggestion" do
        before do
          within "#travel_plan_flights_attributes_0_#{place} + .typeahead" do
            find(option, text: "London Heathrow (LHR)").click
          end
        end

        it "fills the input with the chosen suggestion" do
          wait_for_ajax
          field = find("#travel_plan_flights_attributes_0_#{place}")
          expect(field.value).to eq "London Heathrow (LHR)"
        end

        it "fills in the '#{place}' hidden input with the dest's ID" do
          hidden_input_selector = "#travel_plan_flights_attributes_0_#{place}_id"
          field = find(hidden_input_selector, visible: false)
          expect(field.value).to eq @lhr.id.to_s
        end
      end
    end
  end

  describe "selecting a departure date"

  describe "filling in the form" do
    describe "with valid details for a 'return' travel plan" do
      before do
      end

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
    before { choose :travel_plan_type_single }

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
    before { choose :travel_plan_type_multi }

    it "shows the 'add flight' button" do
      is_expected.to have_selector add_flight_btn
    end

    it "doesn't shows a 'remove flight' button" do
      is_expected.not_to have_selector remove_flight_btn
    end

    describe "and clicking 'add flight'" do
      before { find(add_flight_btn).click }

      it "adds a form for a second travel flight" do
        is_expected.to have_selector flight_form, count: 2
      end

      it "shows the 'remove flight' buttons" do
        is_expected.to have_selector remove_flight_btn, count: 2
      end

      describe "and clicking 'remove flight' again" do
        before { all(remove_flight_btn).first.click }

        it "removes the given travel flight form" do
          is_expected.to have_selector flight_form, count: 1
        end

        it "hides the remaining 'remove flight' button" do
          is_expected.not_to have_selector remove_flight_btn
        end
      end
    end # clicking 'add flight'

    %i[single return].each do |type|
      describe "then clicking '#{type}'" do
        before { choose :"travel_plan_type_#{type}" }
        it "hides the add/remove buttons again" do
          is_expected.not_to have_selector add_flight_btn
          is_expected.not_to have_selector remove_flight_btn
        end
      end
    end

    describe "and adding the maximum number of travel flights" do
      it "disables the 'add flight' button"

      describe "and removing a flight again" do
        it "reenables the 'add flight' button"
      end
    end

    describe "and submitting the form" do
      describe "with valid data"
      describe "with invalid data"
    end
  end

  def flight_field(position, attribute)
    :"travel_plan_flights_attributes_#{position}_#{attribute}"
  end

  def add_flight_btn
    "#add-flight-btn"
  end

  def remove_flight_btn
    ".remove-flight-btn"
  end

  def flight_form
    ".flight-form"
  end

end
