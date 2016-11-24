require 'rails_helper'

require 'seeder'

# some simple smoke tests for the 'seed' rake tasks. I keep forgetting to
# update the seed tasks when I e.g. make changes to the DB. Some simple
# high-levels tests should help me catch this mistake in future.  TODO
# finishing extracting other seed tasks to the Seeder module, and add tests
RSpec.describe Seeder do
  example '.seed_admins' do
    expect do
      described_class.seed_admins
    end.to change { Admin.count }.by(3)
    expect(Admin.pluck(:email)).to match_array(%w[
                                                 erik@abroaders.com
                                                 george@abroaders.com
                                                 aj@abroaders.com
                                               ],)
  end

  example '.seed_alliances' do
    expect do
      described_class.seed_alliances
    end.to change { Alliance.count }.by(4)
    expect(Alliance.pluck(:name)).to match_array(
      %w[OneWorld StarAlliance SkyTeam Independent],
    )
  end

  example '.seed_banks' do
    expect do
      described_class.seed_banks
    end.to change { Bank.count }.by(12)

    expect(Bank.pluck(:name)).to match_array([
                                               'American Express',
                                               'Bank of America',
                                               'Barclays',
                                               'Capital One',
                                               'Chase',
                                               'Citibank',
                                               'Diners Club',
                                               'Discover',
                                               'SunTrust',
                                               'TD Bank',
                                               'US Bank',
                                               'Wells Fargo',
                                             ],)
  end

  example '.seed_currencies' do
    described_class.seed_alliances

    expect do
      described_class.seed_currencies
    end.to change { Currency.count }.by(53)

    expect(Currency.joins(:alliance).where(alliances: { name: 'OneWorld' }).count).to eq 10
    expect(Currency.joins(:alliance).where(alliances: { name: 'StarAlliance' }).count).to eq 12
    expect(Currency.joins(:alliance).where(alliances: { name: 'SkyTeam' }).count).to eq 6
    expect(Currency.joins(:alliance).where(alliances: { name: 'Independent' }).count).to eq 25
  end

  example '.seed_card_products' do
    described_class.seed_alliances
    described_class.seed_banks
    described_class.seed_currencies
    expect do
      described_class.seed_card_products
    end.to change { Card::Product.count }.by(9)
  end
end
