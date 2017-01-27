require "rails_helper"

RSpec.describe "new travel plan page", :js do
  let(:account) { create(:account, onboarding_state: ob_state) }
  let(:person) { account.owner }

  subject { page }

  let(:ob_state) { :complete }

  before do
    @airports = create_list(:airport, 2)
    login_as_account(account)
    visit new_travel_plan_path
  end

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
      expect(page).to have_selector '.interest-regions-survey'
    end
  end

  context "after onboarding survey" do
    let(:ob_state) { :complete }
    it { is_expected.to have_sidebar }
    it { is_expected.to have_no_link SKIP_LINK }
  end

  it_behaves_like 'a travel plan form'

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

        set_datepicker_field('#travel_plan_depart_on', to: '01/02/2020')
        set_datepicker_field('#travel_plan_return_on', to: '01/02/2025')
      end

      it "creates a travel plan" do
        expect { submit_form }.to change { account.travel_plans.count }.by(1)
      end

      context "when I'm onboarding my first travel plan" do
        let(:ob_state) { :travel_plan }

        it 'takes me to the next page' do
          submit_form
          expect(account.reload.onboarding_state).to eq 'account_type'
          expect(page).to have_selector '#account_type_forms'
        end
      end

      context "when I'm not on the onboarding survey" do
        let(:ob_state) { :complete }

        it 'takes me to the travel plans index' do
          submit_form
          expect(page).to have_selector 'h1', text: /My Travel Plans/
        end
      end
    end

    example "invalid save" do
      # doesn't create a travel plan
      expect { submit_form }.not_to change { TravelPlan.count }
      # shows me the form again
      expect(page).to have_selector 'h2', text: 'Add a Travel Plan'
    end

    example "with an invalid (non-autocompleted) airport" do # bug fix
      fill_in :travel_plan_from, with: 'blah blah blah'
      fill_in :travel_plan_to, with: 'not a real code (ZZZ)'
      raise if Airport.exists?(code: 'ZZZ') # sanity check
      set_datepicker_field('#travel_plan_depart_on', to: '01/02/2020')
      set_datepicker_field('#travel_plan_return_on', to: '01/02/2025')
      expect { submit_form }.not_to change { TravelPlan.count }
    end
  end
end
