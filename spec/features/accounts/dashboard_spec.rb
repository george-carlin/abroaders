require "rails_helper"

describe "account dashboard" do
  subject { page }

  let(:email) { "thedude@lebowski.com" }
  let!(:account) { create(:account, email: email) }
  let!(:me) { account.people.first }

  before do
    login_as_account(account.reload)
    create(:companion, account: account) if has_companion
    visit root_path
  end

  let(:has_companion) { false }

  let(:owner) { account.people.find_by(main: true) }
  let(:partner) { account.people.find_by(main: false) }

  it { is_expected.to have_title full_title }

  context "when the account has a companion" do
    let(:has_companion) { true }
    it "always has the owner on the left" do
      # owner selector goes before partner selector:
      is_expected.to have_selector "##{dom_id(owner)} + ##{dom_id(partner)}"
    end
  end

end
