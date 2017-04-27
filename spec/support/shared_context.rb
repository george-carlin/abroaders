RSpec.shared_context "logged in" do
  let(:account) { create(:account, :onboarded) }
  let(:owner)   { account.owner }
  before { login_as_account(account) }
end

RSpec.shared_context "logged in as admin" do
  let(:admin) { create_admin }
  before { login_as_admin(admin) }
end

RSpec.shared_examples "a travel plan form" do
  it "has inputs for a travel plan", :js do
    expect(page).to have_field :travel_plan_from
    expect(page).to have_field :travel_plan_to
    expect(page).to have_field :travel_plan_no_of_passengers
    expect(page).to have_field :travel_plan_type_one_way
    expect(page).to have_field :travel_plan_type_round_trip, checked: true
    expect(page).to have_field :travel_plan_depart_on
    expect(page).to have_field :travel_plan_return_on
    expect(page).to have_field :travel_plan_further_information
    expect(page).to have_field :travel_plan_accepts_economy
    expect(page).to have_field :travel_plan_accepts_premium_economy
    expect(page).to have_field :travel_plan_accepts_business_class
    expect(page).to have_field :travel_plan_accepts_first_class

    expect(page).to have_field :travel_plan_type_one_way
    if page.has_checked_field?(:travel_plan_type_one_way)
      expect(page).to have_field :travel_plan_return_on, disabled: true
    end

    expect(page).to have_field :travel_plan_type_round_trip
    if page.has_checked_field?(:travel_plan_type_round_trip)
      expect(page).to have_field :travel_plan_return_on
    end

    expect(page).to have_field :travel_plan_further_information
    expect(page).to have_field :travel_plan_accepts_economy
    expect(page).to have_field :travel_plan_accepts_premium_economy
    expect(page).to have_field :travel_plan_accepts_business_class
    expect(page).to have_field :travel_plan_accepts_first_class

    # checking "one-way" disables the return date:
    choose :travel_plan_type_one_way
    expect(page).to have_field :travel_plan_return_on, disabled: true
    choose :travel_plan_type_round_trip
    expect(page).to have_field :travel_plan_return_on, disabled: false
  end
end
