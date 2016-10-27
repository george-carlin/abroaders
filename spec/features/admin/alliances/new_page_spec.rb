require "rails_helper"

describe "admin new alliance" do
  include_context "logged in as admin"
  subject { page }

  let(:account)      { create(:account, :onboarded) }
  let(:new_alliance) { Alliance.last }
  let(:submit_form)  { click_button "Save" }

  before do
    visit new_admin_alliance_path
  end

  it { is_expected.to have_title full_title("New Alliance") }

  it "has inputs for a alliance" do
    form = find("#new_alliance")

    expect(form).to have_field "alliance_name"
    expect(form[:action]).to eq admin_alliances_path
  end

  describe "submitting the form with valid information" do
    before do
      fill_in "alliance_name", with: "New Alliance name"
    end

    it "updates the alliance" do
      expect{submit_form}.to change{Alliance.count}.by(1)
      expect(new_alliance.name).to eq "New Alliance name"
      expect(current_path).to eq admin_alliances_path
    end
  end

  describe "submitting the form with invalid information" do
    before do
      fill_in "alliance_name", with: ""
    end

    it "updates the alliance" do
      expect{submit_form}.to change{Alliance.count}.by(0)
      expect(current_path).to eq admin_alliances_path
    end
  end
end
