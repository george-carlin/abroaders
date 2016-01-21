require "rails_helper"

describe "initial surveys" do
  subject { page }

  context "as a new user" do
    include_context "logged in as new user"

    context "when I have not yet filled in the initial survey" do
      describe "trying to visit any page" do
        it "redirects to the survey" do
          [new_travel_plan_path, current_cards_path].each do |path|
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
  end
end
