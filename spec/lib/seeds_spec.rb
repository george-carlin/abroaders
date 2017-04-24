require 'rails_helper'

require 'seeder'

# some simple smoke tests for the 'seed' rake tasks. I keep forgetting to
# update the seed tasks when I e.g. make changes to the DB. Some simple
# high-levels tests should help me catch this mistake in future.
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

  example '.seed_currencies' do
    expect do
      described_class.seed_currencies
    end.to change { Currency.count }.by(53)

    expect(Currency.where(alliance_name: 'OneWorld').count).to eq 10
    expect(Currency.where(alliance_name: 'StarAlliance').count).to eq 12
    expect(Currency.where(alliance_name: 'SkyTeam').count).to eq 6
    expect(Currency.where(alliance_name: 'Independent').count).to eq 25
  end

  example '.seed_card_products' do
    described_class.seed_currencies
    expect do
      described_class.seed_card_products
    end.to change { CardProduct.count }.by(9)
  end
end
