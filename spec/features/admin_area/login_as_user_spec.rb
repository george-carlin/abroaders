require 'rails_helper'

RSpec.describe 'admin logging in as account' do
  let(:admin) { create_admin }
  let(:account) { create_account(:onboarded) }
  let(:person) { account.owner }
  let!(:currency) { create_currency }

  def click_sign_out
    find('#sign_out_link').click
  end

  # Spec:
  #
  # when an admin is logged in:
  #   they can't visit the admin sign in page
  #   they can't visit the account sign in page

  before do
    login_as_admin(admin)
    visit admin_person_path(person)
  end

  describe 'logging in' do
    before { click_link "Log in as #{person.first_name}" }

    example '' do
      expect(current_path).to eq root_path
      expect(page).to have_content "#{admin.email} as #{account.email}"
      expect(page).to have_selector '.admin-navbar'

      # Add a balance for this person, as a smoke test to make sure the admin
      # can do what the user can.
      visit new_person_balance_path(account.owner)
      select currency.name, from: :balance_currency_id
      fill_in :balance_value, with: 2345

      expect do
        click_button 'Save'
      end.to change { person.balances.count }.by(1)
    end

    example 'and logging out again' do
      click_sign_out

      # Still signed in as admin
      expect(page).to have_selector '.admin-navbar'
      expect(current_path).to eq admin_person_path(person)
      expect(page).to have_content admin.email
      expect(page).to have_no_content "#{admin.email} as #{account.email}"

      # Can't visit person pages
      visit new_person_balance_path(person)
      expect(page).to have_content 'You must sign out'
      expect(current_path).not_to eq new_person_balance_path(person)

      # Signing out as admin too:
      click_sign_out
      expect(page).to have_no_content admin.email
    end
  end
end
