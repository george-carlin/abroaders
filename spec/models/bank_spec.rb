require "rails_helper"

RSpec.describe Bank do
  example '.find' do
    # data pulled from banks.csv
    chase = described_class.find(1)
    expect(chase.name).to eq 'Chase'
    expect(chase.personal_phone).to eq '(888) 609-7805'
    expect(chase.business_phone).to eq '800 453-9719'

    co = described_class.find(9)
    expect(co.name).to eq 'Capital One'
    expect(co.personal_phone).to eq '(800) 625-7866'
    expect(co.business_phone).to eq '(800) 625-7866'
  end

  example '#==' do
    expect(Bank.find(5)).to eq Bank.find(5)
  end

  example '.with_at_least_one_product' do
    expect(Bank.with_at_least_one_product).to eq []

    chase = Bank.find_by_name!('Chase')
    citi = Bank.find_by_name!('Citibank')
    amex = Bank.find_by_name!('American Express')

    create(:card_product, bank: chase)
    expect(Bank.with_at_least_one_product).to eq [chase]

    create(:card_product, bank: chase)
    create(:card_product, bank: citi)
    expect(Bank.with_at_least_one_product).to match_array [chase, citi]

    create(:card_product, bank: citi)
    create(:card_product, bank: amex)
    expect(Bank.with_at_least_one_product).to match_array [chase, citi, amex]
  end
end
