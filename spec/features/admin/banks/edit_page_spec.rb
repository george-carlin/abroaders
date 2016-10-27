require "rails_helper"

describe "admin edit bank" do
  include_context "logged in as admin"
  subject { page }

  let(:account)     { create(:account, :onboarded) }
  let(:bank)        { create(:bank, name: "My bank") }
  let(:submit_form) { click_button "Save" }

  before do
    visit edit_admin_bank_path(bank)
  end

  it { is_expected.to have_title full_title("Edit Bank") }

  it "has inputs for a bank" do
    form = find("#edit_bank_#{bank.id}")

    expect(form).to have_field("bank_name", with: bank.name)
    expect(form).to have_field("bank_personal_phone", with: bank.personal_phone)
    expect(form).to have_field("bank_business_phone", with: bank.business_phone)
    expect(form[:action]).to eq admin_bank_path(bank)
  end

  describe "submitting the form with valid information" do
    before do
      fill_in("bank_name", with: "New bank name")
      fill_in("bank_personal_phone", with: "1000-1000")
      fill_in("bank_business_phone", with: "8000-8000")
    end

    it "updates the bank" do
      expect{submit_form}.to change{Bank.count}.by(0)
      bank.reload
      expect(bank.name).to           eq "New bank name"
      expect(bank.personal_phone).to eq "1000-1000"
      expect(bank.business_phone).to eq "8000-8000"
      expect(current_path).to eq admin_banks_path
    end
  end

  describe "submitting the form with invalid information" do
    before do
      fill_in "bank_name", with: ""
    end

    it "updates the bank" do
      expect{submit_form}.to change{Bank.count}.by(0)
      bank.reload
      expect(bank.name).to eq "My bank"
      expect(current_path).to eq admin_bank_path(bank)
    end
  end
end
