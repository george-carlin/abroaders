require "rails_helper"

describe "admin edit alliance" do
  include_context "logged in as admin"
  subject { page }

  let(:account)     { create(:account, :onboarded) }
  let(:alliance)    { create(:alliance, name: "My Alliance") }
  let(:submit_form) { click_button "Save" }

  before do
    visit edit_admin_alliance_path(alliance)
  end

  it { is_expected.to have_title full_title("Edit Alliance") }

  it "has inputs for a alliance" do
    form = find("#edit_alliance_#{alliance.id}")

    expect(form[:action]).to eq admin_alliance_path(alliance)
    expect(form).to have_field("alliance_name", with: alliance.name)
  end

  describe "submitting the form with valid information" do
    before do
      fill_in "alliance_name", with: "New Alliance name"
    end

    it "updates the alliance" do
      expect{submit_form}.to change{Alliance.count}.by(0)
      alliance.reload
      expect(alliance.name).to eq "New Alliance name"
      expect(current_path).to eq admin_alliances_path
    end
  end

  describe "submitting the form with invalid information" do
    before do
      fill_in "alliance_name", with: ""
    end

    it "updates the alliance" do
      expect{submit_form}.to change{Alliance.count}.by(0)
      alliance.reload
      expect(alliance.name).to eq "My Alliance"
      expect(current_path).to eq admin_alliance_path(alliance)
    end
  end
end
