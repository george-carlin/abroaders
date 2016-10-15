require "rails_helper"

describe "travel plans" do
  let(:account) { create(:account, onboarding_state: :travel_plan) }
  let(:person) { account.owner }

  subject { page }

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
    login_as(account)
  end

  def onboard_first_travel_plan!
    account.update_attributes!(onboarded_travel_plans: true)
  end

  def complete_onboarding_survey!
    account.update_attributes!(onboarded_type: true, onboarded_travel_plans: true, onboarded_home_airports: true)
    account.owner.update_attributes!(eligible: false, onboarded_balances: true)
  end

  let(:depart_date) { 5.months.from_now.to_date }
  let(:return_date) { 6.months.from_now.to_date }

  let(:submit_form) { click_button "Save" }

  describe "new page", :onboarding do
    let(:visit_path) do
      login_as(account)
      visit new_travel_plan_path
    end

    SKIP_LINK = "I don't have specific plans".freeze

    example "after onboarding survey" do
      complete_onboarding_survey!
      visit_path
      expect(page).to have_sidebar
      expect(page).to have_no_link SKIP_LINK
    end

    example "as part of onboarding survey" do
      visit_path
      expect(page).to have_no_sidebar
      expect(page).to have_link SKIP_LINK
    end

    example "skipping adding a travel plan in onboarding survey" do
      visit_path
      expect do
        click_link SKIP_LINK
      end.not_to change { TravelPlan.count }

      # marks travel plans as onboarded:
      expect(account.reload.onboarded_travel_plans).to eq true

      # shows the next page of the survey:
      expect(current_path).to eq survey_interest_regions_path
    end

    describe '' do
      before { visit_path }
      it_behaves_like "a travel plan form"
    end

    it "lists countries in the 'from/to' dropdowns" do
      visit_path
      from_options = all("#travel_plan_from_id > option")
      to_options   = all("#travel_plan_to_id   > option")

      country_names = @countries.map(&:name)
      from_names    = country_names + ["From"]
      to_names      = country_names + ["To"]

      expect(from_options.map(&:text)).to match_array from_names
      expect(to_options.map(&:text)).to   match_array to_names
    end

    example "default options" do
      visit_path

      expect(page).to have_field :travel_plan_type_return, checked: true
      expect(page).to have_field :travel_plan_type_single
      expect(page).to have_field :travel_plan_no_of_passengers

      expect(page).to have_field :travel_plan_departure_date, with: ""
      expect(page).to have_field :travel_plan_return_date, with: ""
    end

    describe "filling in the form" do
      before { visit_path }

      context "with valid information" do
        let(:further_info) { "Something" }
        before do
          create(:travel_plan, :return, account: account)
          select "United States", from: :travel_plan_from_id
          select "Vietnam",       from: :travel_plan_to_id
          # Don't test the JS datepicker for now
          fill_in :travel_plan_departure_date, with: depart_date.strftime("%m/%d/%Y")
          fill_in :travel_plan_return_date, with: return_date.strftime("%m/%d/%Y")
          fill_in :travel_plan_no_of_passengers, with: 2
          fill_in :travel_plan_further_information, with: further_info
          check :travel_plan_will_accept_economy
          check :travel_plan_will_accept_premium_economy
          check :travel_plan_will_accept_business_class
          check :travel_plan_will_accept_first_class
        end

        context "with trailing whitespace" do
          before do
            fill_in :travel_plan_departure_date,  with: " #{depart_date.strftime("%m/%d/%Y")} "
            fill_in :travel_plan_further_information, with: " Something "
            submit_form
          end

          it "strips the trailing whitespace" do
            plan = account.reload.travel_plans.last
            expect(plan.depart_on).to eq depart_date
            expect(plan.return_on).to eq return_date
            expect(plan.further_information).to eq "Something"
          end
        end

        context "when further information is blank" do
          let(:further_info) { "" }
          it "is valid" do
            expect { submit_form }.to change { account.travel_plans.count }.by(1)
          end
        end

        it "creates a travel plan" do
          expect { submit_form }.to change { account.travel_plans.count }.by(1)
          plan   = account.reload.travel_plans.last
          flight = plan.flights.first
          expect(flight.from).to eq @us
          expect(flight.to).to eq @vn
          # Don't test the JS datepicker for now
          expect(plan.depart_on).to eq depart_date
          expect(plan.no_of_passengers).to eq 2
          expect(plan.further_information).to eq "Something"
          expect(plan.will_accept_economy?).to be_truthy
          expect(plan.will_accept_premium_economy?).to be_truthy
          expect(plan.will_accept_business_class?).to be_truthy
          expect(plan.will_accept_first_class?).to be_truthy
        end

        describe "after submit" do
          context "if I was onboarding my account" do
            it "takes me to the next onboarding page" do
              submit_form
              expect(current_path).to eq type_account_path
              account.reload
              expect(account.onboarding_state).to eq "account_type"
            end
          end

          context "if I was not onboarding_my_account", onboarding: false do
            before { complete_onboarding_survey! }
            it "takes me to the travel plans index" do
              submit_form
              expect(current_path).to eq travel_plans_path
              expect(account.reload.onboarding_state).to eq "complete"
            end
          end
        end
      end

      context "with invalid information" do
        it "doesn't create a travel plan" do
          expect { submit_form }.not_to change { TravelPlan.count }
        end

        it "shows me the form again" do
          submit_form
          expect(page).to have_selector "h2", text: "Add a Travel Plan"
        end
      end
    end
  end

  describe "edit page" do
    let(:account) { create(:account, :onboarded) }
    let!(:travel_plan) { create(:travel_plan, :return, account: account) }
    before do
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
        expect(flight.from).to eq @uk
        expect(flight.to).to eq @tl
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
end
