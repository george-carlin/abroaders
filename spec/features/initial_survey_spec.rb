require "rails_helper"

describe "initial surveys" do
  subject { page }

  context "as a new user" do
    include_context "logged in as new user"

    context "when I have not yet provided any contact details" do
      describe "trying to visit any page" do
        it "redirects to the 'new contact details' page" do
          [new_travel_plan_path, new_spending_info_path].each do |path|
            puts path
            visit path
            expect(current_path).to eq new_user_info_path
          end
        end

        pending "it also redirects from root_path" do
          # leave this until we've created a proper 'dashboard' or whatever for
          # logged on users on the root path
          visit root_path
          expect(current_path).to eq new_user_info_path
        end
      end
    end

    context "when I have provided my contact details" do
      before { user.create_info!(attributes_for(:user_info)) }

      context "but have not provided my spending info" do
        describe "trying to visit any page" do
          it "redirects to the 'new contact details' page" do
            [new_travel_plan_path, new_user_info_path].each do |path|
              visit path
              expect(current_path).to eq new_spending_info_path
            end
          end

          pending "it also redirects from root_path" do
            # leave this until we've created a proper 'dashboard' or whatever for
            # logged on users on the root path
            visit root_path
            expect(current_path).to eq new_spending_info_path
          end
        end
      end
    end
  end
end
