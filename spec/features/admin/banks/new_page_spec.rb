require "rails_helper"

describe "admin new bank" do
  include_context "logged in as admin"
  subject { page }

  let(:account)     { create(:account, :onboarded) }
  let(:new_bank)    { Bank.last }
  let(:submit_form) { click_button "Save" }

  before do
    visit new_admin_bank_path
  end

  it { is_expected.to have_title full_title("New Bank") }

  it "has inputs for a bank" do
    form = find("#new_bank")

    expect(form).to(have_field("bank_name"))
    expect(form).to(have_field("bank_personal_phone"))
    expect(form).to(have_field("bank_business_phone"))
    expect(form[:action]).to eq admin_banks_path
  end

  describe "submitting the form with valid information" do
    before do
      fill_in("bank_name", with: "New bank name")
      fill_in("bank_personal_phone", with: "1000-1000")
      fill_in("bank_business_phone", with: "8000-8000")
    end

    it "updates the bank" do
      expect { submit_form }.to change { Bank.count }.by(1)
      expect(new_bank.name).to           eq "New bank name"
      expect(new_bank.personal_phone).to eq "1000-1000"
      expect(new_bank.business_phone).to eq "8000-8000"
      expect(current_path).to eq admin_banks_path
    end
  end

  describe "submitting the form with invalid information" do
    before do
      fill_in "bank_name", with: ""
    end

    it "updates the bank" do
      expect { submit_form }.to change { Bank.count }.by(0)
      expect(current_path).to eq admin_banks_path
    end
  end
end
