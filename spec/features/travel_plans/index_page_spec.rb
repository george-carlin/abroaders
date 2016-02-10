require "rails_helper"

describe "travel plans page" do
  subject { page }

  include_context "logged in"

  before { visit travel_plans_path }

  example "placeholder test" do
    is_expected.to have_selector "h1", text: "Travel Plans"
  end

  pending "add some examples to (or delete) #{__FILE__}"
end
