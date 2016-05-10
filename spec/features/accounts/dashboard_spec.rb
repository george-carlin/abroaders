require "rails_helper"

describe "account dashboard" do
  subject { page }

  let(:email) { "thedude@lebowski.com" }
  let!(:account) { create(:account, email: email) }
  let!(:me) { account.people.first }

  before do
    extra_setup
    login_as_account(account.reload)
    create(:person, main: false, account: account) if has_companion
    visit root_path
  end

  let(:has_companion) { false }

  let(:main) { account.people.find_by(main: true) }
  let(:partner) { account.people.find_by(main: false) }

  it { is_expected.to have_title full_title }

  context "when the account has a companion" do
    let(:has_companion) { true }
    it "always has the main passenger on the left" do
      # main passenger selector goes before partner selector:
      is_expected.to have_selector "##{dom_id(main)} + ##{dom_id(partner)}"
    end
  end

  let(:extra_setup) { nil }

  def within_my_info
    within("##{dom_id(me)}") { yield }
  end

  def within_companion
    within("##{dom_id(account.companion)}") { yield }
  end

end
