require 'rails_helper'

require 'seeder'

# some simple smoke tests for the 'seed' rake tasks. I keep forgetting to
# update the seed tasks when I e.g. make changes to the DB. Some simple
# high-levels tests should help me catch this mistake in future.  TODO
# finishing extracting other seed tasks to the Seeder module, and add tests
describe Seeder do
  example '.seed_alliances' do
    expect do
      described_class.seed_alliances
    end.to change { Alliance.count }.by(4)
    expect(Alliance.pluck(:name)).to match_array(
      %w[OneWorld StarAlliance SkyTeam Independent],
    )
  end

  example '.seed_currencies' do
    Seeder.seed_alliances

    expect do
      described_class.seed_currencies
    end.to change { Currency.count }.by(53)

    expect(Currency.joins(:alliance).where(alliances: { name: 'OneWorld' }).count).to eq 10
    expect(Currency.joins(:alliance).where(alliances: { name: 'StarAlliance' }).count).to eq 12
    expect(Currency.joins(:alliance).where(alliances: { name: 'SkyTeam' }).count).to eq 6
    expect(Currency.joins(:alliance).where(alliances: { name: 'Independent' }).count).to eq 25
  end
end
