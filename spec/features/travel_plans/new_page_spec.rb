require "rails_helper"

describe "travel plans page" do

  let(:account) { create(:account) }
  let!(:me) { create(:person, account: account) }

  subject { page }

  before do
    @eu = create(:region, name: "Europe")
    @us = create(:region, name: "United States")
    @as = create(:region, name: "Asia")
    @countries = [
      @uk = create(:country, name: "United Kingdom", parent: @eu),
      @us = create(:country, name: "United States",  parent: @us),
      @vn = create(:country, name: "Vietnam",        parent: @as),
      @tl = create(:country, name: "Thailand",       parent: @as),
      @fr = create(:country, name: "France",         parent: @eu),
    ]
    login_as(account)
  end

  let(:submit_form) { click_button "Save" }
  let(:date) { 5.months.from_now.to_date }

  def fill_in_form_with_valid_information
    select "United States", from: :travel_plan_from_id
    select "Vietnam",       from: :travel_plan_to_id
    # Don't test the JS datepicker for now
    fill_in :travel_plan_earliest_departure, with: date.strftime("%m/%d/%Y")
    fill_in :travel_plan_no_of_passengers, with: 2
    fill_in :travel_plan_further_information, with: "Something"
    check :travel_plan_will_accept_economy
    check :travel_plan_will_accept_premium_economy
    check :travel_plan_will_accept_business_class
    check :travel_plan_will_accept_first_class
  end

  before { visit new_travel_plan_path }

  it "has inputs for a new travel plan" do
    is_expected.to have_field :travel_plan_earliest_departure
    is_expected.to have_field :travel_plan_from_id
    is_expected.to have_field :travel_plan_no_of_passengers
    is_expected.to have_field :travel_plan_to_id
    is_expected.to have_field :travel_plan_type_single
    is_expected.to have_field :travel_plan_type_return
    is_expected.to have_field :travel_plan_further_information
    is_expected.to have_field :travel_plan_will_accept_economy
    is_expected.to have_field :travel_plan_will_accept_premium_economy
    is_expected.to have_field :travel_plan_will_accept_business_class
    is_expected.to have_field :travel_plan_will_accept_first_class
  end

  describe "'type'" do
    it "is 'return' by default" do
      type_radios = all("input[name='travel_plan[type]']")
      selected = type_radios.detect { |r| r[:checked] }
      expect(selected.value).to eq "return"
    end
  end

  describe "'# of passengers'" do
    it "is '1' by default" do
      expect(find("#travel_plan_no_of_passengers").value).to eq "1"
    end
  end

  describe "'earliest departure'" do
    it "is today's date by default" do
      today = Date.today.strftime("%m/%d/%Y")
      expect(find("#travel_plan_earliest_departure").value).to eq today
    end
  end

  it "includes all countries, but not regions, in the 'from/to' dropdowns" do
    from_options = all("#travel_plan_from_id > option")
    to_options   = all("#travel_plan_to_id   > option")

    country_names = @countries.map(&:name)
    from_names    = country_names + ["Select a country of origin"]
    to_names      = country_names + ["Select a destination country"]

    expect(from_options.map(&:text)).to match_array from_names
    expect(to_options.map(&:text)).to   match_array to_names
  end

  describe "filling in the form" do
    context "with valid information" do
      let(:date) { 5.months.from_now.to_date }
      before do
        select "United States", from: :travel_plan_from_id
        select "Vietnam",       from: :travel_plan_to_id
        # Don't test the JS datepicker for now
        fill_in :travel_plan_earliest_departure, with: date.strftime("%m/%d/%Y")
        fill_in :travel_plan_no_of_passengers, with: 2
        fill_in :travel_plan_further_information, with: "Something"
        check :travel_plan_will_accept_economy
        check :travel_plan_will_accept_premium_economy
        check :travel_plan_will_accept_business_class
        check :travel_plan_will_accept_first_class
      end

      context "with trailing whitespace" do
        before do
          fill_in :travel_plan_earliest_departure,  with: " #{date.strftime("%m/%d/%Y")} "
          fill_in :travel_plan_further_information, with: " Something "
          submit_form
        end

        it "strips the trailing whitespace" do
          plan = account.reload.travel_plans.last
          expect(plan.earliest_departure).to eq date
          expect(plan.further_information).to eq "Something"
        end
      end

      it "creates a travel plan" do
        expect{submit_form}.to change{account.travel_plans.count}.by(1)
        plan   = account.reload.travel_plans.last
        flight = plan.flights.first
        expect(flight.from).to eq @us
        expect(flight.to).to eq @vn
        # Don't test the JS datepicker for now
        expect(plan.earliest_departure).to eq date
        expect(plan.no_of_passengers).to eq 2
        expect(plan.further_information).to eq "Something"
        expect(plan.will_accept_economy?).to be_truthy
        expect(plan.will_accept_premium_economy?).to be_truthy
        expect(plan.will_accept_business_class?).to be_truthy
        expect(plan.will_accept_first_class?).to be_truthy
      end
    end

    context "with invalid information" do
      it "doesn't create a travel plan" do
        expect{submit_form}.not_to change{TravelPlan.count}
      end

      it "shows me the form again" do
        submit_form
        expect(page).to have_selector "h1", text: "Add a Travel Plan"
      end
    end
  end

  describe "submitting a valid travel plan" do
    before do
      create(:travel_plan, account: account) unless first_travel_plan
      fill_in_form_with_valid_information
      submit_form
    end

    context "if this is my first ever travel plan" do
      let(:first_travel_plan) { true }
      it "takes me to the spending survey" do
        expect(current_path).to eq new_person_spending_info_path(me)
      end
    end

    context "if this is not my first ever travel plan" do
      let(:first_travel_plan) { false }
      it "takes me to the travel plans index" do
        expect(current_path).to eq travel_plans_path
      end
    end
  end
end
