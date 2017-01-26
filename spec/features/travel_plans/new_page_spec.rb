require "rails_helper"

describe "new travel plan page", :js do
  let(:account) { create(:account, onboarding_state: ob_state) }
  let(:person) { account.owner }

  subject { page }

  let(:ob_state) { :travel_plan }

  before do
    @airports = create_list(:airport, 2)
    login_as_account(account)
    visit new_travel_plan_path
  end

  let(:depart_date) { 5.months.from_now.to_date }
  let(:return_date) { 6.months.from_now.to_date }

  let(:submit_form) { click_button 'Save my travel plan' }

  SKIP_LINK = "I don't have specific plans".freeze

  context "as part of onboarding survey" do
    let(:ob_state) { :travel_plan }
    it { is_expected.to have_no_sidebar }
    it { is_expected.to have_link SKIP_LINK }

    example "skipping adding a travel plan" do
      expect { click_link SKIP_LINK }.not_to change { TravelPlan.count }
      account.reload
      expect(account.onboarding_state).to eq "regions_of_interest"
      expect(current_path).to eq survey_interest_regions_path
    end
  end

  context "after onboarding survey" do
    let(:ob_state) { :complete }
    it { is_expected.to have_sidebar }
    it { is_expected.to have_no_link SKIP_LINK }
  end

  specify 'has correct fields' do
    expect(page).to have_field :travel_plan_from
    expect(page).to have_field :travel_plan_to
    expect(page).to have_field :travel_plan_no_of_passengers
    expect(page).to have_field :travel_plan_type_single
    expect(page).to have_field :travel_plan_type_return, checked: true
    expect(page).to have_field :travel_plan_depart_on
    expect(page).to have_field :travel_plan_return_on
    expect(page).to have_field :travel_plan_further_information
    expect(page).to have_field :travel_plan_accepts_economy
    expect(page).to have_field :travel_plan_accepts_premium_economy
    expect(page).to have_field :travel_plan_accepts_business_class
    expect(page).to have_field :travel_plan_accepts_first_class
  end

  specify 'checking "single" disables the return date' do
    choose :travel_plan_type_single
    expect(page).to have_field :travel_plan_return_on, disabled: true
    choose :travel_plan_type_return
    expect(page).to have_field :travel_plan_return_on, disabled: false
  end

  example "showing points estimate table" do
    expect(page).to have_no_selector ".PointsEstimateTable"
    # choosing two airports
    code_0 = @airports[0].code
    code_1 = @airports[1].code
    fill_in_typeahead("#travel_plan_from", with: code_0, and_choose: code_0)
    wait_for_ajax
    expect(page).to have_no_selector ".PointsEstimateTable"
    fill_in_typeahead("#travel_plan_to", with: code_1, and_choose: code_1)
    expect(page).to have_selector ".PointsEstimateTable"
  end

  describe "filling in the form" do
    context "with valid information" do
      before do
        create(:travel_plan, :return, account: account)
        fill_in_typeahead(
          "#travel_plan_from",
          with:       @airports[0].code,
          and_choose: "(#{@airports[0].code})",
        )

        fill_in_typeahead(
          "#travel_plan_to",
          with:       @airports[1].code,
          and_choose: "(#{@airports[1].code})",
        )

        set_datepicker_field('#travel_plan_depart_on', to: depart_date)
        set_datepicker_field('#travel_plan_return_on', to: return_date)
        fill_in :travel_plan_no_of_passengers, with: 2
        fill_in :travel_plan_further_information, with: 'Something'
        check :travel_plan_accepts_economy
        check :travel_plan_accepts_premium_economy
        check :travel_plan_accepts_business_class
        check :travel_plan_accepts_first_class
      end

      it "creates a travel plan" do
        expect { submit_form }.to change { account.travel_plans.count }.by(1)
        plan   = account.reload.travel_plans.last
        flight = plan.flights.first
        expect(flight.from).to eq @airports[0]
        expect(flight.to).to eq @airports[1]
        expect(plan.depart_on).to eq depart_date
        expect(plan.return_on).to eq return_date
        expect(plan.no_of_passengers).to eq 2
        expect(plan.further_information).to eq 'Something'
        expect(plan.accepts_economy?).to be true
        expect(plan.accepts_premium_economy?).to be true
        expect(plan.accepts_business_class?).to be true
        expect(plan.accepts_first_class?).to be true
      end
    end

    example "invalid save" do
      # doesn't create a travel plan
      expect { submit_form }.not_to change { TravelPlan.count }
      # shows me the form again
      submit_form
      expect(page).to have_selector 'h2', text: 'Add a Travel Plan'
    end

    example "with an invalid (non-autocompleted) airport" do # bug fix
      fill_in :travel_plan_from, with: 'blah blah blah'
      fill_in :travel_plan_to, with: 'not a real code (ZZZ)'
      raise if Airport.exists?(code: 'ZZZ') # sanity check
      set_datepicker_field('#travel_plan_depart_on', to: depart_date)
      set_datepicker_field('#travel_plan_return_on', to: return_date)
      expect { submit_form }.not_to change { TravelPlan.count }
    end
  end
end
