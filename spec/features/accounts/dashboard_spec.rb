require "rails_helper"

describe "account dashboard" do
  let(:email) { "thedude@lebowski.com" }
  let(:account) { create(:account, email: email) }

  before { login_as_account(account.reload) }

  let(:visit_path) { visit root_path }

  let(:owner)     { account.owner }
  let(:companion) { account.companion }

  specify "account owner appears on the LHS of the page" do
    create(:companion, account: account)
    visit_path
    # owner selector goes before companion selector:
    expect(page).to have_selector "##{dom_id(owner)} + ##{dom_id(companion)}"
  end

end
