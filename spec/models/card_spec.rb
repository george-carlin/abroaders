require "rails_helper"

describe Card do

  let(:card) { described_class.new }

  describe "#bank" do
    it "looks up and returns the Bank using bank_id" do
      card.bank_id = 1
      bank         = card.bank
      expect(bank).to eq Bank.find(1)
      expect(bank.name).to eq "Chase"
    end
  end

  describe "#bank_id=" do
    it "resets the memoized bank" do
      card.bank_id  = 1
      memoized_bank = card.bank
      card.bank_id  = 3
      expect(card.bank).not_to eq memoized_bank
    end
  end

end
