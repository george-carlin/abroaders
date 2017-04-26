require 'cells_helper'

RSpec.describe Abroaders::Cell::Sidebar do
  example '.show?' do
    expect(described_class.show?(nil)).to be false
    expect(described_class.(nil).show?).to be false

    acc = Account.new
    expect(described_class.show?(acc)).to be false
    expect(described_class.(acc).show?).to be false

    # shown when account is onboarded:
    acc.onboarding_state = 'complete'
    expect(described_class.show?(acc)).to be true
    expect(described_class.(acc).show?).to be true

    # admins can always see sidebar:
    admin = Admin.new
    expect(described_class.show?(admin)).to be true
    expect(described_class.(admin).show?).to be true
  end
end
