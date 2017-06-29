require 'cells_helper'

RSpec.describe Abroaders::Cell::Layout::Navbar do
  controller ApplicationController

  example 'not signed in' do
    rendered = cell(nil).()

    # has links to sign in/up
    expect(rendered).to have_link 'Sign up', href: new_account_registration_path
    expect(rendered).to have_link 'Sign in', href: new_account_session_path

    # shows the regular logo
    expect(rendered).to have_selector '#logo:not(.admin-navbar)'

    # has no search bar for accounts
    expect(rendered).not_to have_selector '#admin_accounts_search_bar'
  end

  example 'when signed in as account' do
    account = Account.new(email: 'account@example.com')
    rendered = cell(nil, current_account: account).()

    expect(rendered).to have_content account.email

    # has a link to sign out
    expect(rendered).to have_link('', href: destroy_account_session_path)
    # shows the regular logo
    expect(rendered).to have_selector '#logo:not(.admin-navbar)'
    # has no search bar for accounts
    expect(rendered).not_to have_selector '#admin_accounts_search_bar'
  end

  example 'when signed in as admin' do
    admin = Admin.new(email: 'admin@example.com')
    rendered = cell(nil, current_admin: admin).()

    expect(rendered).to have_content admin.email
    # has a link to sign out
    expect(rendered).to have_link('', href: destroy_admin_session_path)
    # shows the admin logo
    expect(rendered).to have_selector '#logo.admin-navbar'
    # has a search bar for accounts
    expect(rendered).to have_selector '#admin_accounts_search_bar'
  end
end
