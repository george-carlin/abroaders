require "rails_helper"

describe "admin edit travel plan" do
  include_context "logged in as admin"
  subject { page }

  let(:account) { create(:account, :onboarded) }
  let(:travel_plan) { create(:travel_plan, account: account) }
  let(:date) { 5.months.from_now.to_date }
  let(:submit_form) { click_button "Save" }

  before do
    @eu = create(:region, name: "Europe")
    @us = create(:region, name: "United States")
    @as = create(:region, name: "Asia")
    @countries = [
      @uk = create(:country, name: "United Kingdom", parent: @eu),
      @ha = create(:country, name: "Hawaii",         parent: @us),
      @al = create(:country, name: "Alaska",         parent: @us),
      @us = create(:country, name: "United States (Continental 48)", parent: @us),
      @vn = create(:country, name: "Vietnam",        parent: @as),
      @tl = create(:country, name: "Thailand",       parent: @as),
      @fr = create(:country, name: "France",         parent: @eu),
    ]

    visit edit_admin_travel_plan_path(travel_plan)
  end

  it_behaves_like "a travel plan form"

  it { is_expected.to have_title full_title("Edit Travel Plan") }

  it "form filled for admin" do
    form = find("#edit_travel_plan_#{travel_plan.id}")
    owner_name = account.owner.first_name

    expect(form[:action]).to eq admin_travel_plan_path(travel_plan)
    expect(form).to have_content "What class(es) of service would #{owner_name} consider for this trip?"
    expect(form).to have_no_selector(".help-block")
    expect(form.find("#travel_plan_further_information")[:placeholder]).to eq "Optional: give us any extra information about #{owner_name}'s travel plans that you think might be relevant"
  end

  it "lists countries in the 'from/to' dropdowns" do
    from_options = all("#travel_plan_from_id > option")
    to_options   = all("#travel_plan_to_id   > option")
    country_names = @countries.map(&:name)
    expect(from_options.map(&:text)).to match_array country_names
    expect(to_options.map(&:text)).to   match_array country_names
  end

  describe "submitting the form with valid information" do
    before do
      select "United Kingdom", from: :travel_plan_from_id
      select "Thailand",       from: :travel_plan_to_id
      fill_in :travel_plan_earliest_departure, with: date.strftime("%m/%d/%Y")
      fill_in :travel_plan_no_of_passengers, with: 2
      fill_in :travel_plan_further_information, with: "Something"
      check :travel_plan_will_accept_economy
      check :travel_plan_will_accept_premium_economy
      check :travel_plan_will_accept_business_class
      check :travel_plan_will_accept_first_class
    end

    it "updates the travel plan" do
      submit_form
      travel_plan.reload
      flight = travel_plan.flights.first
      expect(flight.from).to eq @uk
      expect(flight.to).to eq @tl
      expect(travel_plan.earliest_departure).to eq date
      expect(travel_plan.no_of_passengers).to eq 2
      expect(travel_plan.further_information).to eq "Something"
      expect(travel_plan.will_accept_economy?).to be_truthy
      expect(travel_plan.will_accept_premium_economy?).to be_truthy
      expect(travel_plan.will_accept_business_class?).to be_truthy
      expect(travel_plan.will_accept_first_class?).to be_truthy
    end
  end
end
