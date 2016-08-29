require "rails_helper"

describe "edit readiness page", :js do
  let(:account) { create(:account, :onboarded_cards, :onboarded_balances) }
  let(:person)  { account.owner }

  before do
    person.update_attributes!(eligible: true, ready: false)
    login_as(account)
    visit person_readiness_path(person)
  end

  let(:click_ready_btn) { click_button "I am now ready" }

  example "updating my status to 'ready'" do
    click_ready_btn
    expect(person.reload).to be_ready
  end

  example "tracking an Intercom event", :intercom do
    expect{click_ready_btn}.to \
      track_intercom_event("obs_ready_own").for_email(account.email)
  end
end
