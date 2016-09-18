require "rails_helper"

describe Currency do

  let(:currency) { described_class.new }

  describe "#alliance" do
    it "looks up and returns the Alliance using alliance_id" do
      currency.alliance_id = 1
      alliance = currency.alliance
      expect(alliance).to eq Alliance.find(1)
      expect(alliance.name).to eq "OneWorld"
    end

    it "returns nil if alliance_id is nil" do
      expect(currency.alliance_id).to be nil
      expect(currency.alliance).to be nil
    end
  end

  describe "#alliance_id=" do
    it "resets the memoized alliance" do
      currency.alliance_id  = 1
      memoized_alliance = currency.alliance
      currency.alliance_id  = 3
      expect(currency.alliance).not_to eq memoized_alliance
    end
  end

  describe "#alliance=" do
    let(:alliance_0) { Alliance.find(1) }
    let(:alliance_1) { Alliance.find(3) }

    it "sets the alliance and alliance_id" do
      currency.alliance = alliance_0
      expect(currency.alliance_id).to eq alliance_0.id
      expect(currency.alliance).to eq alliance_0
    end

    it "resets any memoized alliance" do
      currency.alliance = alliance_0
      currency.alliance = alliance_1
      expect(currency.alliance_id).to eq alliance_1.id
      expect(currency.alliance).to eq alliance_1
    end
  end
end
