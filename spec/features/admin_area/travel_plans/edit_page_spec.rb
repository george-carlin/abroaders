require "rails_helper"

RSpec.describe "admin edit travel plan" do
  # travel plan form needs updating because some old travel plans are to/from
  # countries but new ones are to/from airports. Not sure how to handle this.
  before { skip 'tests need updating' }
  include_context "logged in as admin"
  subject { page }

  let(:account) { create_account(:onboarded) }
  let(:travel_plan) { create_travel_plan(type: :round_trip, account: account) }
  let(:depart_date) { 5.months.from_now.to_date }
  let(:return_date) { 6.months.from_now.to_date }
  let(:submit_form) { click_button "Save" }

  before do
    @airports = create_list(:airport, 5)
    visit edit_admin_travel_plan_path(travel_plan)
  end

  it_behaves_like "a travel plan form"

  it { is_expected.to have_title full_title("Edit Travel Plan") }

  it "form filled for admin" do
    form = find("#edit_travel_plan_#{travel_plan.id}")
    owner_name = account.owner.first_name

    expect(form[:action]).to eq admin_travel_plan_path(travel_plan)
    expect(form).to have_no_selector(".help-block")
    expect(form.find("#travel_plan_further_information")[:placeholder]).to eq "Optional: give us any extra information about #{owner_name}'s travel plans that you think might be relevant"
  end

  describe "submitting the form with valid information", :js do
    before do
      fill_in_autocomplete("travel_plan_from_typeahead", @airports[0].code)
      fill_in_autocomplete("travel_plan_to_typeahead", @airports[1].code)
      fill_in :travel_plan_depart_on, with: depart_date.strftime("%m/%d/%Y")
      fill_in :travel_plan_return_on, with: return_date.strftime("%m/%d/%Y")
      fill_in :travel_plan_no_of_passengers, with: 2
      fill_in :travel_plan_further_information, with: "Something"
      check :travel_plan_accepts_economy
      check :travel_plan_accepts_premium_economy
      check :travel_plan_accepts_business_class
      check :travel_plan_accepts_first_class
    end

    it "updates the travel plan" do
      submit_form
      travel_plan.reload
      flight = travel_plan.flights.first
      expect(flight.from).to eq @airports[0]
      expect(flight.to).to eq @airports[1]
      expect(travel_plan.depart_on).to eq depart_date
      expect(travel_plan.return_on).to eq return_date
      expect(travel_plan.no_of_passengers).to eq 2
      expect(travel_plan.further_information).to eq "Something"
      expect(travel_plan.accepts_economy?).to be_truthy
      expect(travel_plan.accepts_premium_economy?).to be_truthy
      expect(travel_plan.accepts_business_class?).to be_truthy
      expect(travel_plan.accepts_first_class?).to be_truthy
    end
  end
end
