require "rails_helper"

describe "new travel plans page", js: true do

  subject { page }

  include_context "logged in"

  before do
    visit new_travel_plans_path
  end

  it "has a form to add a 'return' travel plan"

  describe "searching for an airport in the 'from' input" do
    it "populates the dropdown with suggestions"

    describe "and choosing a suggestion" do
      it "fills the input with the chosen suggestion"
    end
  end

  describe "searching for an airport in the 'to' input" do
    it "populates the dropdown with suggestions"

    describe "and choosing a suggestion" do
      it "fills the input with the chosen suggestion"
    end
  end

  describe "selecting a departure date"
  describe "selecting a return date"

  describe "filling in the form" do
    describe "with valid details for a 'return' travel plan" do
      describe "and clicking 'save'" do
        it "creates a return travel plan"

        pending "TODO: what does it show me next?"
      end
    end

    describe "with invalid details for a 'return' travel plan" do
      pending
    end
  end

  describe "clicking 'single'" do
    it "disables the 'return date' input"

    describe "and clicking 'return' again" do
      it "reenables the 'return date' input"
    end

    describe "and filling in the form" do
      describe "with valid details for a single travel plan" do
        describe "and clicking 'save'" do
          it "creates a single travel plan"

          pending "TODO: what does it show me next?"
        end
      end

      describe "with invalid details for a single travel plan" do
        describe "and clicking 'save'" do
          pending
        end
      end
    end
  end

  describe "clicking 'multi'" do
    it "shows the 'add/remove leg' buttons"

    describe "the first 'remove leg' button" do
      it "is initially disabled"
    end

    describe "and clicking 'add leg'" do
      it "adds a form for a second travel leg"
      it "enables the 'remove leg' buttons"

      describe "and clicking 'remove leg' again" do
        it "removes the travel leg form"
        it "disables the 'remove leg' buttons"
      end
    end

    describe "and adding the maximum number of travel legs" do
      it "disables the 'add leg' buttons"

      describe "and removing a leg again" do
        it "reenables the 'add leg' buttons"
      end
    end

    describe "and submitting the form" do
      describe "with valid data"
      describe "with invalid data"
    end
  end

end
