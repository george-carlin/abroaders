require "rails_helper"

describe "signing up" do
  subject { page }

  before { visit new_user_registration_path }

  it "has fields to create a new user" do
    is_expected.to have_field :user_email
    is_expected.to have_field :user_password
    is_expected.to have_field :user_password_confirmation
  end

  describe "submitting the form" do
    let(:submit_form) { click_button "Sign up" }

    # The external HTTP calls to Stripe on the front and back ends are all
    # stubbed out with the magic of stripe-ruby-mock.
    describe "with valid user information" do
      before do
        fill_in :user_email, with: "testuser@example.com"
        fill_in :user_password, with: "password123"
        fill_in :user_password_confirmation, with: "password123"
      end

      it "creates a new user" do
        expect{ submit_form }.to change{User.count}.by(1)
      end

      describe "the created user" do
        before { submit_form }

        it "has the correct attributes" do
          user = User.last
          expect(user.email).to eq "testuser@example.com"
        end
      end

      describe "after submit" do
        before { submit_form }
        it "takes me to a page to add my contact details" do
          should have_field :user_info_first_name
          should have_field :user_info_last_name
        end
      end
    end

    describe "with invalid user information" do
      it "doesn't create a new user" do
        expect{ submit_form }.not_to change{User.count}
      end
    end
  end
end
