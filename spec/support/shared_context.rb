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
    expect(page).to have_field :travel_plan_type_single
    expect(page).to have_field :travel_plan_type_return, checked: true
    expect(page).to have_field :travel_plan_depart_on
    expect(page).to have_field :travel_plan_return_on
    expect(page).to have_field :travel_plan_further_information
    expect(page).to have_field :travel_plan_accepts_economy
    expect(page).to have_field :travel_plan_accepts_premium_economy
    expect(page).to have_field :travel_plan_accepts_business_class
    expect(page).to have_field :travel_plan_accepts_first_class

    expect(page).to have_field :travel_plan_type_single
    if page.has_checked_field?(:travel_plan_type_single)
      expect(page).to have_field :travel_plan_return_on, disabled: true
    end

    expect(page).to have_field :travel_plan_type_return
    if page.has_checked_field?(:travel_plan_type_return)
      expect(page).to have_field :travel_plan_return_on
    end

    expect(page).to have_field :travel_plan_further_information
    expect(page).to have_field :travel_plan_accepts_economy
    expect(page).to have_field :travel_plan_accepts_premium_economy
    expect(page).to have_field :travel_plan_accepts_business_class
    expect(page).to have_field :travel_plan_accepts_first_class

    # checking "single" disables the return date:
    choose :travel_plan_type_single
    expect(page).to have_field :travel_plan_return_on, disabled: true
    choose :travel_plan_type_return
    expect(page).to have_field :travel_plan_return_on, disabled: false
  end
end

RSpec.shared_context 'create_rec avoids extra records' do
  before(:all) do
    @admin = create_admin
    @offer = create_offer
  end
  after(:all) { [@admin, @offer].each(&:destroy) }

  # Don't create a new admin/offer every time the parent macro is called:
  def create_rec(opts = {})
    super(opts.merge(admin: @admin, offer: @offer))
  end
end

# context for testing cells which are subclasses of or otherwise related
# to Abroaders::Cell::RecommendationAlert
RSpec.shared_context 'recommendation alert cell' do
  include_context 'create_rec avoids extra records'
  controller ApplicationController

  # cells should raise an error if you try to render them for an account where
  # they shouldn't be shown in the first place; use this macro to test this.
  def is_invalid
    expect { described_class.(account).to_s }.to raise_error(ArgumentError)
  end
end
