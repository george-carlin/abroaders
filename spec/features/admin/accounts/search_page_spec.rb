require 'rails_helper'

module AdminArea
  describe 'searching for accounts', :js do
    include_context 'logged in as admin'
    let!(:account) { create(:account) }
    before { visit root_path }

    # there doesn't seem to be a way to simulate an 'enter' hit natively
    # with capybara, so we have to trigger the form submit using JS :(

    example 'search with results' do
      fill_in :accounts_search, with: account.email
      execute_script 'document.getElementById("admin_accounts_search_bar").submit();'
      expect(page).to have_content account.email
    end

    example 'search with no results' do
      fill_in :accounts_search, with: 'blah blah blah'
      execute_script 'document.getElementById("admin_accounts_search_bar").submit();'
      expect(page).to have_content "No results for 'blah blah blah'"
    end
  end
end
