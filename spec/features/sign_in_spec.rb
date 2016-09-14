require "rails_helper"

describe "the sign in page" do
  before do
    @pw = "foobar123"

    attrs = { password: @pw, password_confirmation: @pw }

    if onboarded
      @account = create(:account, :onboarded, attrs)
    else
      @account = create(:account, attrs)
    end

    visit new_account_session_path
  end

  let(:onboarded) { true }

  it "has fields for signing in" do
    expect(page).to have_field :account_email
    expect(page).to have_field :account_password
  end

  describe "submitting the form" do
    let(:submit_form) { click_button "Sign in" }

    describe "with my valid logon details" do
      before do
        fill_in :account_email,    with: @account.email
        fill_in :account_password, with: @pw
        submit_form
      end

      it "signs me in" do
        expect(page).to have_selector "#sign_out_link"
        expect(page).to have_content @account.email
        expect(page).to have_no_content "Sign in"
      end

      context "when I am onboarded" do
        let(:onboarded) { true }

        it "takes me to the dashboard" do
          expect(current_path).to eq root_path
        end
      end

      context "when I am not onboarded" do
        let(:onboarded) { false }

        it "takes me to my next step in the onboarding survey" do
          expect(current_path).to eq survey_airports_path
          # TODO test the other cases; i.e. when I'm at different stages in the
          # survey
        end
      end
    end

    describe "with invalid logon details" do
      before { submit_form }
      it "doesn't sign me in" do
        expect(page).to have_content "Sign in"
        expect(page).to have_no_selector "#sign_out_link"
        expect(page).to have_no_content @account.email
      end
    end
  end
end
