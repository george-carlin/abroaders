require "rails_helper"

RSpec.describe "the admin sign in page" do
  before do
    @pw    = "foobar123"
    @admin = create_admin(password: @pw, password_confirmation: @pw)
    visit new_admin_session_path
  end

  it "has fields for signing in" do
    expect(page).to have_field :admin_email
    expect(page).to have_field :admin_password
  end

  describe "submitting the form" do
    let(:submit_form) { click_button "Sign in" }

    describe "with my valid logon details" do
      before do
        fill_in :admin_email,    with: @admin.email
        fill_in :admin_password, with: @pw
        submit_form
      end

      it "signs me in" do
        expect(page).to have_selector "#sign_out_link"
        expect(page).to have_content @admin.email
        expect(page).to have_no_content "Sign in"
      end
    end

    describe "with invalid logon details" do
      before { submit_form }
      it "doesn't sign me in" do
        expect(page).to have_content "Sign in"
        expect(page).to have_no_selector "#sign_out_link"
        expect(page).to have_no_content @admin.email
      end
    end
  end
end
