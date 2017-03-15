require "rails_helper"

module AdminArea
  RSpec.describe "destinations pages" do
    include_context "logged in as admin"

    example "destinations index" do
      country = create(:country, region_code: Region.codes)
      city    = create(:city,    parent: country)
      airport = create(:airport, parent: city)

      visit admin_destinations_path

      Region.all do |region|
        expect(page).to have_content region.name
      end

      expect(page).to have_content country.name
      expect(page).to have_content city.name
      expect(page).to have_content airport.name
    end
  end
end
