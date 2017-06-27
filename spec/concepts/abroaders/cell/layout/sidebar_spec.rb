require 'cells_helper'

RSpec.describe Abroaders::Cell::Layout::Sidebar do
  controller ApplicationController

  example '.show?' do
    expect(described_class.(nil).show?).to be false

    acc = Account.new
    expect(described_class.(acc).show?).to be false

    # shown when account is onboarded:
    acc.onboarding_state = 'complete'
    expect(described_class.(acc).show?).to be true

    # admins can always see sidebar:
    admin = Admin.new
    expect(described_class.(admin).show?).to be true
  end

  example 'for admin' do
    admin = Admin.new
    sidebar = cell(admin).()
    expect(sidebar).to have_content 'Banks'
    expect(sidebar).to have_content 'Card Products'
    expect(sidebar).to have_content 'Destinations'
    expect(sidebar).to have_content 'My Account'
    expect(sidebar).to have_content 'Offers'
    expect(sidebar).to have_content 'View all offers'
    expect(sidebar).to have_content 'Review live offers'
    expect(sidebar).to have_content 'Users'
  end
end
