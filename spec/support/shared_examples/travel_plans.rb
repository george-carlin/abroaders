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

  describe "the 'from'/'to' dropdowns" do
    def get_options(attr)
      all("#travel_plan_#{attr}_id option")
    end

    specify "have the US, Alaska, and Hawaii sorted to the top" do
      [:from, :to].each do |attr|
        options = get_options(attr)
        if current_path =~ /edit/
          start = 0
        else
          expect(options[0].text).to eq "From" if attr == :from
          expect(options[0].text).to eq "To" if attr == :to
          start = 1
        end

        expect(options[start].text).to eq @us.name
        expect(options[start + 1].text).to eq @al.name
        expect(options[start + 2].text).to eq @ha.name
      end
    end

    specify "subsequent options are sorted alphabetically" do
      options_to_drop = current_path =~ /edit/ ? 3 : 4

      [:from, :to].each do |attr|
        options = get_options(attr)
        expect(options.drop(options_to_drop).map(&:text)).to eq [
          "France",
          "Thailand",
          "United Kingdom",
          "Vietnam",
        ]
      end
    end
  end
end
