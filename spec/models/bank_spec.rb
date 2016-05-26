require "rails_helper"

describe Bank do

  example ".find" do
    result = Bank.find(1)
    expect(result).to be_a(Bank)
    expect(result.id).to eq 1
  end

  example "#name" do
    bank = Bank.find(1)
    expect(bank.name).to eq "Chase"
  end

  example "#cards" do
    cards = create_list(:card, 2, bank_id: 1)
    create(:card, bank_id: 3) # for other bank
    expect(Bank.find(1).cards).to match_array(cards)
  end

  it "can be used as a hash key" do
    bank = Bank.find(1)

    hash = {}

    hash[bank] = "foo"
    hash[bank] = "bar"
    hash[bank] = "buzz"

    expect(hash.keys).to eq [bank]
    expect(hash[bank]).to eq "buzz"
  end

  example "#==" do
    b0 = Bank.find(1)
    b1 = Bank.find(1)
    b2 = Bank.find(3)
    expect(b0 == b1).to be true
    expect(b0 == b2).to be false
  end

end
