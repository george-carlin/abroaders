shared_examples "a travel plan form" do
  it "has inputs for a new travel plan" do
    expect(page).to have_field :travel_plan_departure_date
    expect(page).to have_field :travel_plan_from_id
    expect(page).to have_field :travel_plan_no_of_passengers
    expect(page).to have_field :travel_plan_to_id

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
