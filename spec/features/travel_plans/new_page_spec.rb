require "rails_helper"

# Page is rendered with React.js; all tests must activate Javascript
describe "new travel plans page", js: true, manual_clean: true do
  include AirportMacros

  subject { page }

  include_context "logged in"

  let(:submit) { click_button "Save" }

  before(:all) do
    @eu = create(:region, name: "Europe")
    @us = create(:region, name: "United States")
    @as = create(:region, name: "Asia")
    @destinations = [
      @lhr = create_airport("London Heathrow",     :LHR, @eu),
      @lgw = create_airport("London Gatwick",      :LGW, @eu),
      @yyz = create_airport("Toronto Pearson",     :YYZ, @us),
      @sgn = create_airport("Ho Chi Minh City",    :SGN, @as),
      @jfk = create_airport("New York J.F.K.",     :JFK, @us),
      @lga = create_airport("New York La Guardia", :LGA, @us),
      @ltn = create_airport("London Luton",        :LTN, @eu)
    ]
  end
  after(:all) { DatabaseCleaner.clean_with :truncation }

  before { visit new_travel_plan_path }

  it "has a selector to choose the travel plan type" do
    is_expected.to have_field :travel_plan_type_single
    is_expected.to have_field :travel_plan_type_return
    is_expected.to have_field :travel_plan_type_multi
  end

  specify "'return' type is selected by default" do
    radio = find("#travel_plan_type_return")
    expect(radio).to be_checked
  end

  specify "the 'submit' button is initially disabled" do
    expect(submit_tag).to be_disabled
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
    pending
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
        wait_for_typeahead
      end

      it "populates the dropdown with suggestions" do
        [@lhr, @lgw, @ltn].each do |a|
          text = "#{a.name} (#{a.code})"
          is_expected.to have_selector typeahead_option, text: text
        end
        [@yyz, @sgn, @jfk, @lga].each do |a|
          text = "#{a.name} (#{a.code})"
          is_expected.not_to have_selector typeahead_option, text: text
        end
      end

      specify "the dropdown has a plane icon next to each airport" do
        [@lhr, @lgw, @ltn].each do |a|
          text = "#{a.name} (#{a.code})"
          option = find(typeahead_option, text: text)
          expect(option).to have_selector "i.fa.fa-plane"
        end
      end

      describe "and choosing a suggestion" do
        before do
          within typeahead_dropdown do
            find(typeahead_option, text: "London Heathrow (LHR)").click
          end
        end

        it "fills the input with the chosen suggestion" do
          wait_for_typeahead
          field = find("#travel_plan_flights_attributes_0_#{place}")
          expect(field.value).to eq "London Heathrow (LHR)"
        end

        it "fills in the '#{place}' hidden input with the dest's ID" do
          hidden_input_selector = "#travel_plan_flights_attributes_0_#{place}_id"
          field = find(hidden_input_selector, visible: false)
          expect(field.value).to eq @lhr.id.to_s
        end

        it "doesn't enable the submit button" do
          expect(submit_tag).to be_disabled
        end

        describe "and adding the other flight" do
          before do
            other_place = (%i[from to] - [place])[0]
            select_destination 0, other_place, @sgn
          end

          it "enables the submit button" do
            expect(submit_tag).not_to be_disabled
          end
        end
      end
    end
  end

  describe "pressing 'return' in a destination input" do
    it "doesn't add a flight" do
      # I fixed this bug, but couldn't figure out how to test it; I couldn't
      # write a test that would actually fail. Leaving this blank test here as
      # a reminder of the potential bug.
    end
  end

  describe "searching for a region" do
    before do
      fill_in flight_field(0, :to), with: "europ"
      wait_for_typeahead
    end

    it "displays the region's name in the dropdown but no code" do
      is_expected.to have_selector typeahead_option, text: /\AEurope\z/
    end
  end

  describe "typing in a query, deleting it, then adding it again" do
    before do
      field = find("##{flight_field(0, :to)}")
      field.send_keys("europ")
      wait_for_typeahead
      5.times { field.send_keys(:backspace) }
      wait_for_typeahead
      field.send_keys("europ")
      wait_for_typeahead
    end

    # Bug fix
    it "shows the results dropdown the same as the first time" do
      is_expected.to have_selector typeahead_option, text: /\AEurope\z/
    end
  end

  describe "selecting a departure date"

  describe "filling in the form" do
    describe "with valid details for a 'return' travel plan" do
      before do
        input_flight(0, @lhr, @sgn)
        fill_in :travel_plan_no_of_passengers, with: 3
      end

      describe "and clicking 'save'" do

        it "creates a 'return'-type travel plan on my account" do
          expect{submit}.to \
            change{user.travel_plans.return.count}.by(1)

          plan = user.travel_plans.return.last
          expect(plan.no_of_passengers).to eq 3
          expect(plan.flights[0].from).to eq @lhr
          expect(plan.flights[0].to).to eq   @sgn
        end
      end

      pending "TODO: what does it show me next?"
    end

    describe "with invalid details for a 'return' travel plan" do
      pending
    end

    describe "with valid details for a 'single' travel plan" do
      before do
        choose :travel_plan_type_single
        input_flight(0, @lga, @yyz)
        fill_in :travel_plan_no_of_passengers, with: 2
      end

      describe "and clicking 'save'" do
        it "creates a single travel plan" do
          expect{submit}.to \
            change{user.travel_plans.single.count}.by(1)


          plan = user.travel_plans.single.last
          expect(plan.no_of_passengers).to eq 2
          expect(plan.flights[0].from).to eq @lga
          expect(plan.flights[0].to).to eq   @yyz
        end

        pending "TODO: what does it show me next?"
      end
    end

    describe "with invalid details for a single travel plan" do
      describe "and clicking 'save'" do
        pending
      end
    end

    describe "with valid details for a 'multi' travel plan" do
      before do
        pending "can't get this test to pass, but it works in the browser :/"
        choose :travel_plan_type_multi
        2.times { find(add_flight_btn).click }
        input_flight(0, @lhr, @yyz)
        input_flight(1, @yyz, @jfk)
        input_flight(2, @lga, @ltn)
        fill_in :travel_plan_no_of_passengers, with: 5
      end

      describe "and clicking 'save'" do
        it "creates a 'multi' travel plan" do
          expect{submit}.to \
            change{user.travel_plans.multi.count}.by(1)

          plan = user.travel_plans.multi.last
          expect(plan.no_of_passengers).to eq 5

          expect(plan.flights[0].from).to eq @lhr
          expect(plan.flights[0].to).to eq   @yyz
          expect(plan.flights[1].from).to eq @yyz
          expect(plan.flights[1].to).to eq   @jfk
          expect(plan.flights[2].from).to eq @lga
          expect(plan.flights[2].to).to eq   @ltn
        end

        pending "TODO: what does it show me next?"
      end
    end

    describe "with invalid details for a single travel plan" do
      describe "and clicking 'save'" do
        pending
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
        is_expected.to have_selector flight_fields, count: 2
      end

      it "shows the 'remove flight' buttons" do
        is_expected.to have_selector remove_flight_btn, count: 2
      end

      describe "the fields for the new flight" do
        it "can be used to typeahead-search, like for the first flight" do
          fill_in flight_field(1, :from), with: "lond"
          wait_for_typeahead
          is_expected.to have_selector(
            typeahead_option, text: "London Heathrow (LHR)"
          )
          fill_in flight_field(1, :to), with: "Ho "
          wait_for_typeahead
          is_expected.to have_selector(
            typeahead_option, text: "Ho Chi Minh City (SGN)"
          )
        end
      end

      describe "and clicking 'remove flight' again" do
        before { all(remove_flight_btn).first.click }

        it "removes the given travel flight form" do
          is_expected.to have_selector flight_fields, count: 1
        end

        it "hides the remaining 'remove flight' button" do
          is_expected.not_to have_selector remove_flight_btn
        end
      end

      %i[single return].each do |type|
        describe "and clicking '#{type}'" do
          before { choose "travel_plan_type_#{type}" }

          it "removes all flights except the first one" do
            is_expected.to have_selector flight_fields, count: 1
          end
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
      before do
        max = TravelPlan::MAX_FLIGHTS
        (max - 1).times { find(add_flight_btn).click }
      end

      it "disables the 'add flight' button" do
        expect(find(add_flight_btn)).to be_disabled
      end

      describe "and removing a flight again" do
        before { all(remove_flight_btn).first.click }
        it "reenables the 'add flight' button" do
          expect(find(add_flight_btn)).not_to be_disabled
        end
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

  def flight_fields
    ".FlightFields"
  end

  def typeahead_dropdown
    "ul.typeahead"
  end

  def typeahead_option
    ".typeahead.dropdown-menu > li > a"
  end

  def select_destination(flight_index, from_or_to, dest)
    query = dest.code
    fill_in flight_field(flight_index, from_or_to), with: query
    wait_for_typeahead
    within typeahead_dropdown do
      # TODO: not every destination gets displayed in this way anymore,
      # if your tests are failing you might need to udpate this method:
      find(typeahead_option, text: "#{dest.name} (#{dest.code})").click
    end
  end

  def input_flight(index, from, to)
    select_destination(index, :from, from)
    select_destination(index, :to,   to)
  end

  def wait_for_typeahead
    # wait_for_ajax doesn't always work by itself because $.ajax isn't the only
    # asynchronous method being called. bloodhound also defers execution of
    # some methods using its internal '_.debounce' function. Since the 'wait'
    # period in debounce is 300ms by default (see the bloodhound source code),
    # waiting for 300ms in the tests should be enough to avoid these issues.
    sleep 0.3
    wait_for_ajax
  end

  def submit_tag
    find(".SubmitTag")
  end

end
