require "rails_helper"

module AdminArea
  describe "admin banks index page" do
    include_context "logged in as admin"

    example "initial content" do
      banks = create_list(:bank, 10)

      visit admin_banks_path

      banks.each do |bank|
        expect(page).to have_content bank.id
        expect(page).to have_content bank.name
        expect(page).to have_content bank.personal_phone
        expect(page).to have_content bank.business_phone
        expect(page).to have_link("Edit", href: edit_admin_bank_path(bank))
        expect(page).to have_link("Delete", href: admin_bank_path(bank))
      end
    end
  end
end
