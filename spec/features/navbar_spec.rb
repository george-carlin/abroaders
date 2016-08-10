require "rails_helper"

describe "navbar" do
  before do
    @original_ignore_hidden_elements = Capybara.ignore_hidden_elements
    Capybara.ignore_hidden_elements = false
  end
  after { Capybara.ignore_hidden_elements = @original_ignore_hidden_elements }

  context "when I am not logged in" do
    before { visit root_path }

    describe "the collapsible (mobile) navbar" do
      it "has 'Sign in' and 'Sign up' links but no 'Sign out'" do
        within "#mobile-collapse" do
          expect(page).to have_link "Sign in"
          expect(page).to have_link "Sign up"
          expect(page).to have_no_link "Sign out"
        end
      end
    end
  end

  context "when I am logged in as a normal user" do
    include_context "logged in"
    before { visit root_path }

    describe "the collapsible (mobile) navbar" do
      it "has a 'Sign out' link but no 'Sign in' or 'Sign up'" do
        within "#mobile-collapse" do
          expect(page).to have_no_link "Sign in"
          expect(page).to have_no_link "Sign up"
          expect(page).to have_link "Sign out"
        end
      end
    end
  end
end
