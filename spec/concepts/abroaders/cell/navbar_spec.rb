require 'rails_helper'

RSpec.describe Abroaders::Cell::Navbar, type: :view do
  class Controller # haaaaack :(
    include Rails.application.routes.url_helpers
  end
  let(:context) { { controller: Controller.new } }

  subject(:cell) { described_class.(user, context: context).to_s }

  context 'when not signed in' do
    subject(:user) { nil }

    it 'has links to sign in/up' do
      expect(cell).to have_link 'Sign up', href: new_account_registration_path
      expect(cell).to have_link 'Sign in', href: new_account_session_path
    end

    it 'shows the regular logo' do
      expect(cell).to have_selector '#logo:not(.admin-navbar)', text: /Abroaders\s*\z/
    end

    it 'has no search bar for accounts' do
      expect(cell).not_to have_selector '#admin_accounts_search_bar'
    end
  end

  context 'when signed in as account' do
    let(:user) { Account.new(email: 'admin@example.com') }

    it 'has a link to sign out' do
      expect(cell).to have_link('', href: destroy_account_session_path)
    end

    it 'shows the regular logo' do
      expect(cell).to have_selector '#logo:not(.admin-navbar)', text: /Abroaders\s*\z/
    end

    it 'has no search bar for accounts' do
      expect(cell).not_to have_selector '#admin_accounts_search_bar'
    end
  end

  context 'when signed in as admin' do
    let(:user) { Admin.new(email: 'admin@example.com') }

    it 'has a link to sign out' do
      expect(cell).to have_link('', href: destroy_admin_session_path)
    end

    it 'shows the admin logo' do
      expect(cell).to have_selector '#logo.admin-navbar', text: 'Abroaders (Admin)'
    end

    it 'has a search bar for accounts' do
      expect(cell).to have_selector '#admin_accounts_search_bar'
    end
  end
end
