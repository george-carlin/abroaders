shared_context "logged in as new user" do
  let(:account) { create(:account) } unless defined? account
  before { login_as(account) }
end

shared_context "logged in" do
  let(:account) { create(:account, :onboarded) } unless defined? account
  before { login_as(account) }
end

shared_context "logged in as admin" do
  let(:admin) { create(:admin) }
  before { login_as_admin(admin) }
end

shared_examples "a travel plan form" do
  it "has inputs for a travel plan", :js do
    expect(page).to have_field "travel_plan_from_typeahead"
    expect(page).to have_field "travel_plan_to_typeahead"
    expect(page).to have_selector "#travel_plan_from_code", visible: false
    expect(page).to have_selector "#travel_plan_to_code", visible: false
    expect(page).to have_field :travel_plan_no_of_passengers

    expect(page).to have_field :travel_plan_type_single
    if page.has_checked_field?(:travel_plan_type_single)
      expect(page).to have_field :travel_plan_return_date, disabled: true
    end

    expect(page).to have_field :travel_plan_type_return
    if page.has_checked_field?(:travel_plan_type_return)
      expect(page).to have_field :travel_plan_return_date
    end

    expect(page).to have_field :travel_plan_further_information
    expect(page).to have_field :travel_plan_will_accept_economy
    expect(page).to have_field :travel_plan_will_accept_premium_economy
    expect(page).to have_field :travel_plan_will_accept_business_class
    expect(page).to have_field :travel_plan_will_accept_first_class
  end
end
