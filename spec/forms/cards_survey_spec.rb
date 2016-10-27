require "rails_helper"

describe CardsSurvey do
  let(:survey) { described_class.new }

  describe "#each_section" do
    it "yields cards grouped by bank, then by b/p" do
      currency = create(:currency)
      b0 = create(:bank)
      b1 = create(:bank)

      c0 = create(:card, :personal, bank: b0, currency: currency)
      c1 = create(:card, :personal, bank: b0, currency: currency)
      c2 = create(:card, :business, bank: b0, currency: currency)
      c3 = create(:card, :business, bank: b0, currency: currency)
      c4 = create(:card, :personal, bank: b1, currency: currency)
      c5 = create(:card, :personal, bank: b1, currency: currency)
      c6 = create(:card, :business, bank: b1, currency: currency)
      c7 = create(:card, :business, bank: b1, currency: currency)

      banks = []
      bank_groups = {}
      survey.each_section do |bank, cards_grouped_by_bp|
        banks << bank
        bank_groups[bank.name] = cards_grouped_by_bp
      end

      expect(banks).to match_array [b0, b1]

      expect(bank_groups[b0.name]["personal"]).to match_array([c0, c1])
      expect(bank_groups[b0.name]["business"]).to match_array([c2, c3])
      expect(bank_groups[b1.name]["personal"]).to match_array([c4, c5])
      expect(bank_groups[b1.name]["business"]).to match_array([c6, c7])
    end
  end
end
