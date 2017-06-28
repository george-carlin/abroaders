require 'cells_helper'

RSpec.describe Abroaders::Cell::Layout::Navbar do
  controller ApplicationController

  example 'not signed in' do
    rendered = cell(nil).()

    # it 'has links to sign in/up' do
    expect(rendered).to have_link 'Sign up', href: new_account_registration_path
    expect(rendered).to have_link 'Sign in', href: new_account_session_path

    # it 'shows the regular logo' do
    expect(rendered).to have_selector '#logo:not(.admin-navbar)'

    # it 'has no search bar for accounts' do
    expect(rendered).not_to have_selector '#admin_accounts_search_bar'
  end

  example 'when signed in as account' do
    user = Account.new(email: 'admin@example.com')
    rendered = cell(user).()

    # it 'has a link to sign out' do
    expect(rendered).to have_link('', href: destroy_account_session_path)
    # it 'shows the regular logo' do
    expect(rendered).to have_selector '#logo:not(.admin-navbar)'
    # it 'has no search bar for accounts' do
    expect(rendered).not_to have_selector '#admin_accounts_search_bar'
  end

  example 'when signed in as admin' do
    user = Admin.new(email: 'admin@example.com')
    rendered = cell(user).()

    # it 'has a link to sign out' do
    expect(rendered).to have_link('', href: destroy_admin_session_path)
    # it 'shows the admin logo' do
    expect(rendered).to have_selector '#logo.admin-navbar'
    # it 'has a search bar for accounts' do
    expect(rendered).to have_selector '#admin_accounts_search_bar'
  end
end
