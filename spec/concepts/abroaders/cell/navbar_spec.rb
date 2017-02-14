require 'cells_helper'

RSpec.describe Abroaders::Cell::Navbar do
  controller ApplicationController

  let(:rendered) { show(user) }

  context 'when not signed in' do
    subject(:user) { nil }

    it 'has links to sign in/up' do
      expect(rendered).to have_link 'Sign up', href: new_account_registration_path
      expect(rendered).to have_link 'Sign in', href: new_account_session_path
    end

    it 'shows the regular logo' do
      expect(rendered).to have_selector '#logo:not(.admin-navbar)', text: /Abroaders\s*\z/
    end

    it 'has no search bar for accounts' do
      expect(rendered).not_to have_selector '#admin_accounts_search_bar'
    end
  end

  context 'when signed in as account' do
    let(:user) { Account.new(email: 'admin@example.com') }

    it 'has a link to sign out' do
      expect(rendered).to have_link('', href: destroy_account_session_path)
    end

    it 'shows the regular logo' do
      expect(rendered).to have_selector '#logo:not(.admin-navbar)', text: /Abroaders\s*\z/
    end

    it 'has no search bar for accounts' do
      expect(rendered).not_to have_selector '#admin_accounts_search_bar'
    end
  end

  context 'when signed in as admin' do
    let(:user) { Admin.new(email: 'admin@example.com') }

    it 'has a link to sign out' do
      expect(rendered).to have_link('', href: destroy_admin_session_path)
    end

    it 'shows the admin logo' do
      expect(rendered).to have_selector '#logo.admin-navbar', text: 'Abroaders (Admin)'
    end

    it 'has a search bar for accounts' do
      expect(rendered).to have_selector '#admin_accounts_search_bar'
    end
  end
end
