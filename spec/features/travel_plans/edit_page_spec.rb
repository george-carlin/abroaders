require 'rails_helper'

describe 'edit travel plan page' do
  include_context 'logged in'
  let(:person) { account.owner }

  subject { page }

  let!(:travel_plan) { create(:travel_plan, :return, account: account) }

  before do
    travel_plan.flights[0].update!(
      from: @airports[0],
      to:   @airports[1],
    )
    login_as(account)
    visit edit_travel_plan_path(travel_plan)
  end

  it_behaves_like "a travel plan form"

  it { is_expected.to have_title full_title("Edit Travel Plan") }

  it "form filled for user" do
    form = find("#edit_travel_plan_#{travel_plan.id}")

    expect(form[:action]).to eq travel_plan_path(travel_plan)
    expect(form.find("#travel_plan_further_information")[:placeholder]).to eq "Optional: give us any extra information about your travel plans that you think might be relevant"
  end

  describe "submitting the form with valid information", :js do
    before do
      fill_in_autocomplete("travel_plan_from_typeahead", @airports[1].code)
      fill_in_autocomplete("travel_plan_to_typeahead", @airports[0].code)
      # Don't test the JS datepicker for now
      fill_in :travel_plan_departure_date, with: depart_date.strftime("%m/%d/%Y")
      fill_in :travel_plan_return_date, with: return_date.strftime("%m/%d/%Y")
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
      expect(flight.from).to eq @airports[1]
      expect(flight.to).to eq @airports[0]
      expect(travel_plan.depart_on).to eq depart_date
      expect(travel_plan.return_on).to eq return_date
      expect(travel_plan.no_of_passengers).to eq 2
      expect(travel_plan.further_information).to eq "Something"
      expect(travel_plan.will_accept_economy?).to be_truthy
      expect(travel_plan.will_accept_premium_economy?).to be_truthy
      expect(travel_plan.will_accept_business_class?).to be_truthy
      expect(travel_plan.will_accept_first_class?).to be_truthy
    end
  end
end
