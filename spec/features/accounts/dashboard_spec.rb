require "rails_helper"

describe "account dashboard" do
  subject { page }

  let(:email) { "thedude@lebowski.com" }
  let!(:account) { create(:account, email: email) }
  let!(:me) { account.people.first }

  before do
    extra_setup
    login_as_account(account.reload)
    visit root_path
  end

  it { is_expected.to have_title full_title }

  let(:extra_setup) { nil }

  def within_my_info
    within("##{dom_id(me)}") { yield }
  end

  def within_companion
    within("##{dom_id(account.companion)}") { yield }
  end

end
