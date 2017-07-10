require 'cells_helper'

RSpec.describe Abroaders::Cell::Layout::Sidebar do
  controller ApplicationController

  let(:sidebar) { described_class }

  example '.show?' do
    admin = Admin.new
    acc = Account.new

    # no-one signed in:
    expect(sidebar.(nil, {}).show?).to be false

    # admin signed in:
    expect(sidebar.(nil, current_admin: admin).show?).to be true

    # non-onboarded account signed in:
    expect(sidebar.(nil, current_account: acc).show?).to be false

    # admin signed in as non-onboarded account:
    expect(sidebar.(nil, current_admin: admin, current_account: acc).show?).to be false

    # onboarded account signed in:
    acc.onboarding_state = 'complete'
    expect(sidebar.(nil, current_account: acc).show?).to be true

    # admin signed in as non-onboarded account:
    expect(sidebar.(nil, current_admin: admin, current_account: acc).show?).to be true
  end

  example 'for admin' do
    admin = Admin.new
    sidebar = cell(nil, current_admin: admin).()

    expect(sidebar).to have_content 'Banks'
    expect(sidebar).to have_content 'Card Products'
    expect(sidebar).to have_content 'Destinations'
    expect(sidebar).to have_content 'My Account'
    expect(sidebar).to have_content 'Offers'
    expect(sidebar).to have_content 'View all offers'
    expect(sidebar).to have_content 'Review live offers'
    expect(sidebar).to have_content 'Users'
    expect(sidebar).to have_content 'Settings'
  end
end
