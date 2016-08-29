require "rails_helper"

describe "readiness survey", :js, :onboarding do
  # TODO make sure all relevant scenarios are covered by the spending survey
  # and its specs, and delete this file
  before { skip }
  include_context "set admin email ENV var"

  before do
    @account = create(:account, onboarded_travel_plans: true, onboarded_type: true)
    @owner   = @account.owner
    @owner.update_attributes!(
      eligible: true,
      onboarded_balances: true,
      onboarded_cards:    true,
    )
    create(:spending_info, person: @account.owner)
    login_as(@account.reload)
  end

  let(:submit_form) { click_button "Confirm" }

  let(:visit_path_for_owner) { visit new_person_readiness_path(@owner) }

  def visit_path_for_companion
    # onboard the owner so we don't get redirected to his page:
    @account.owner.update_attributes(ready: true)
    @companion = create(
      :companion,
      :eligible,
      :onboarded_balances,
      :onboarded_cards,
      :onboarded_spending,
      account: @account,
    )
    visit new_person_readiness_path(@companion)
  end

  example "page layout" do
    visit_path_for_owner
    expect(page).to have_field :person_ready_true, checked: true
    expect(page).to have_field :person_ready_false
    expect(page).to have_no_sidebar
  end

  example "saying I am ready" do
    visit_path_for_owner
    submit_form
    @owner.reload
    expect(@owner).to be_ready
  end

  example "clicking 'not ready' and showing unreadiness reason form" do
    visit_path_for_owner
    choose :person_ready_false
    expect(page).to have_field :person_unreadiness_reason
    choose :person_ready_true
    expect(page).to have_no_field :person_unreadiness_reason
  end

  example "submitting a reason for not being ready" do
    visit_path_for_owner
    choose :person_ready_false
    fill_in :person_unreadiness_reason, with: "because"
    submit_form
    @owner.reload
    expect(@owner.onboarded_readiness?).to be_truthy
    expect(@owner).to be_unready
    expect(@owner.unreadiness_reason).to eq "because"
  end

  pending "saying I am unready queues a reminder email"

  example "tracking 'ready' intercom event for owner" do
    visit_path_for_owner
    expect{submit_form}.to \
      track_intercom_event("obs_ready_own").for_email(@account.email)
  end

  example "tracking 'unready' intercom event for owner" do
    visit_path_for_owner
    choose :person_ready_false
    expect{submit_form}.to \
      track_intercom_event("obs_unready_own").for_email(@account.email)
  end

  example "tracking 'ready' intercom event for companion" do
    visit_path_for_companion
    expect{submit_form}.to \
      track_intercom_event("obs_ready_com").for_email(@account.email)
  end

  example "tracking 'unready' intercom event for companion" do
    visit_path_for_companion
    choose :person_ready_false
    expect{submit_form}.to \
      track_intercom_event("obs_unready_com").for_email(@account.email)
  end
end
