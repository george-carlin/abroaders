require "rails_helper"

module AdminArea
  RSpec.describe "destinations pages" do
    include_context "logged in as admin"

    example "destinations index" do
      region  = create(:region)
      country = create(:country, parent: region)
      city    = create(:city,    parent: country)
      airport = create(:airport, parent: city)

      visit admin_destinations_path

      expect(page).to have_content region.name
      expect(page).to have_content country.name
      expect(page).to have_content city.name
      expect(page).to have_content airport.name
    end
  end
end
