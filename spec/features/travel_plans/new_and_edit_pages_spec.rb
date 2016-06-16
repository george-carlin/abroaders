require "rails_helper"

describe "travel plans" do

  let(:onboarded_travel_plans) { false }
  let(:fully_onboarded) { false }
  let(:account) do
    create(:account, onboarded_travel_plans: onboarded_travel_plans)
  end

  let!(:me) { account.people.first }

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
    if fully_onboarded
      account.update_attributes!(onboarded_type: true)
      create(:spending_info, person: account.people.first)
      account.people.first.eligible_to_apply!
      account.people.first.update_attributes!(
        onboarded_balances: true,
        onboarded_cards:    true,
      )
      account.people.first.ready_to_apply!
    end
    login_as(account)
  end

  let(:date) { 5.months.from_now.to_date }

  let(:submit_form) { click_button "Save" }

  shared_examples "a travel plan form" do
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

    describe "the 'from'/'to' dropdowns" do
      def get_options(attr); all("#travel_plan_#{attr}_id option"); end

      specify "have the US, Alaska, and Hawaii sorted to the top" do
        [:from, :to].each do |attr|
          options = get_options(attr)
          if current_path =~ /edit/
            start = 0
          else
            expect(options[0].text).to match(/Select a\s.*country/)
            start = 1
          end

          expect(options[start].text).to eq @us.name
          expect(options[start + 1].text).to eq @al.name
          expect(options[start + 2].text).to eq @ha.name
        end
      end

      specify "subsequent options are sorted alphabetically" do
        options_to_drop = current_path =~ /edit/ ? 3 : 4

        [:from, :to].each do |attr|
          options = get_options(attr)
          expect(options.drop(options_to_drop).map(&:text)).to eq ([
            "France",
            "Thailand",
            "United Kingdom",
            "Vietnam",
          ])
        end
      end
    end
  end

  describe "new page", :onboarding do
    before { visit new_travel_plan_path }

    SKIP_LINK = "I don't want to add a travel plan right now"

    context "when I have already onboarded my first travel plan" do
      let(:onboarded_travel_plans) { true }
      context "but have not completed the rest of the onboarding process" do
        let(:fully_onboarded) { false }
        it "doesn't allow access" do
          raise if account.onboarded? # sanity check
          expect(current_path).not_to eq new_travel_plan_path
        end
      end

      context "and have completed the rest of the onboarding process" do
        let(:fully_onboarded) { true }
        it "allows access" do
          raise unless account.onboarded? # sanity check
          expect(current_path).to eq new_travel_plan_path
        end

        it "shows the sidebar" do
          is_expected.to have_selector "#menu"
        end
      end
    end

    context "when I have not onboarded my first travel plan" do
      let(:onboarded_travel_plans) { false }

      it "doesn't show the sidebar" do
        is_expected.to have_no_selector "#menu"
      end
    end

    describe "when I have not onboarded my first travel plan" do
      let(:onboarded_travel_plans) { false }
      it "has a link to skip making travel plans" do
        expect(page).to have_link SKIP_LINK
      end
    end

    describe "when I have already onboarded my first travel plan" do
      let(:onboarded_travel_plans) { true }
      it "doesn't have a link to skip making travel plans" do
        expect(page).to_not have_link SKIP_LINK
      end
    end

    describe "when I click the skip travel plans link" do
      let(:onboarded_travel_plans) { false }

      let(:skip_survey) { click_link SKIP_LINK }

      it "changes account values to skip forward" do
        skip_survey
        expect(account.reload.onboarded_travel_plans).to eq true
      end

      it "redirects to the next step in the oboarding survey" do
        skip_survey
        expect(current_path).to eq type_account_path
      end

      it "doesn't create travel plans" do
        expect{skip_survey}.not_to change{TravelPlan.count}
      end
    end



    it_behaves_like "a travel plan form"

    it { is_expected.to have_title full_title("Add a Travel Plan") }

    it "lists countries in the 'from/to' dropdowns" do
      from_options = all("#travel_plan_from_id > option")
      to_options   = all("#travel_plan_to_id   > option")

      country_names = @countries.map(&:name)
      from_names    = country_names + ["Select a country of origin"]
      to_names      = country_names + ["Select a destination country"]

      expect(from_options.map(&:text)).to match_array from_names
      expect(to_options.map(&:text)).to   match_array to_names
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

    describe "filling in the form" do
      context "with valid information" do
        let(:further_info) { "Something" }
        before do
          create(:travel_plan, account: account)
          select "United States", from: :travel_plan_from_id
          select "Vietnam",       from: :travel_plan_to_id
          # Don't test the JS datepicker for now
          fill_in :travel_plan_earliest_departure, with: date.strftime("%m/%d/%Y")
          fill_in :travel_plan_no_of_passengers, with: 2
          fill_in :travel_plan_further_information, with: further_info
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

        context "when further information is blank" do
          let(:further_info) { "" }
          it "is valid" do
            expect{submit_form}.to change{account.travel_plans.count}.by(1)
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

        describe "after submit" do
          before { submit_form }

          context "if I'm not already marked as 'onboarded travel plans'" do
            let(:onboarded_travel_plans) { false }
            it "takes me to account type select page" do
              expect(current_path).to eq type_account_path
            end

            it "marks my account as 'onboarded travel plans'" do
              expect(account.reload).to be_onboarded_travel_plans
            end
          end

          context "if this is not my first ever travel plan", onboarding: false do
            let(:onboarded_travel_plans) { true }
            let(:fully_onboarded) { true }
            it "takes me to the travel plans index" do
              expect(current_path).to eq travel_plans_path
            end

            it "keeps my account marked as 'onboarded travel plans'" do
              expect(account.reload).to be_onboarded_travel_plans
            end
          end
        end
      end

      context "with invalid information" do
        it "doesn't create a travel plan" do
          expect{submit_form}.not_to change{TravelPlan.count}
        end

        it "shows me the form again" do
          submit_form
          expect(page).to have_selector "h2", text: "Add a Travel Plan"
        end
      end
    end
  end

  describe "edit page" do
    let!(:travel_plan) { create(:travel_plan, account: account) }
    before { visit edit_travel_plan_path(travel_plan) }

    it_behaves_like "a travel plan form"

    it { is_expected.to have_title full_title("Edit Travel Plan") }

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
end
