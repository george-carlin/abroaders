require 'rails_helper'

RSpec.describe CardProduct::Survey do
  let(:survey) { described_class.new }

  describe '#each_section' do
    it 'yields cards grouped by bank, then by b/p' do
      currency = create_currency
      b_0 = Bank.all[0]
      b_1 = Bank.all[1]

      c_0 = create(:card_product, :personal, bank_id: b_0.id, currency: currency)
      c_1 = create(:card_product, :personal, bank_id: b_0.id, currency: currency)
      c_2 = create(:card_product, :business, bank_id: b_0.id, currency: currency)
      c_3 = create(:card_product, :business, bank_id: b_0.id, currency: currency)
      c_4 = create(:card_product, :personal, bank_id: b_1.id, currency: currency)
      c_5 = create(:card_product, :personal, bank_id: b_1.id, currency: currency)
      c_6 = create(:card_product, :business, bank_id: b_1.id, currency: currency)
      c_7 = create(:card_product, :business, bank_id: b_1.id, currency: currency)

      banks = []
      bank_groups = {}
      survey.each_section do |bank, cards_grouped_by_bp|
        banks << bank
        bank_groups[bank.name] = cards_grouped_by_bp
      end

      expect(banks).to match_array [b_0, b_1]

      expect(bank_groups[b_0.name]['personal']).to match_array([c_0, c_1])
      expect(bank_groups[b_0.name]['business']).to match_array([c_2, c_3])
      expect(bank_groups[b_1.name]['personal']).to match_array([c_4, c_5])
      expect(bank_groups[b_1.name]['business']).to match_array([c_6, c_7])
    end
  end
end
