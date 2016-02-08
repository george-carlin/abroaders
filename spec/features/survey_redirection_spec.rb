require "rails_helper"

describe "initial surveys" do
  subject { page }

  context "as a new user" do
    include_context "logged in as new user"

    context "who has not filled in the contact/spending info survey" do
      describe "trying to visit any page" do
        it "redirects to the survey" do
          [
            new_travel_plan_path,
            card_accounts_path,
            card_survey_path,
            travel_plans_path
          ].each do |path|
            visit path
            expect(current_path).to eq survey_path
          end
        end

        pending "it also redirects from root_path" do
          # leave this until we've created a proper 'dashboard' or whatever for
          # logged on users on the root path
          visit root_path
          expect(current_path).to eq survey_path
        end
      end
    end

    context "who has filled in the contact/spending info survey" do
      before { create(:user_info, user: user); user.reload }

      context "but not the cards survey" do
        describe "trying to visit any page" do
          it "redirects to the cards survey" do
            [
              new_travel_plan_path,
              card_accounts_path,
              survey_path,
              travel_plans_path
            ].each do |path|
              visit path
              expect(current_path).to eq card_survey_path
            end
          end

          pending "it also redirects from root_path" do
            # leave this until we've created a proper 'dashboard' or whatever for
            # logged on users on the root path
            visit root_path
            expect(current_path).to eq card_survey_path
          end
        end
      end

      context "and the cards survey" do
        pending # add this once we've added the next steps in the survey
      end
    end
  end
end
