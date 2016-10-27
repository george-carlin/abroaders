require "rails_helper"

module AdminArea
  describe "admin alliances index page" do
    include_context "logged in as admin"

    example "initial content" do
      alliances = create_list(:alliance, 10)

      visit admin_alliances_path

      alliances.each do |alliance|
        expect(page).to have_content alliance.id
        expect(page).to have_content alliance.name
        expect(page).to have_link("Edit", href: edit_admin_alliance_path(alliance))
        expect(page).to have_link("Delete", href: admin_alliance_path(alliance))
      end
    end
  end
end
