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
end
