require "rails_helper"

RSpec.describe "factories" do
  describe 'card product factory' do
    it '' do
      expect { create(:card_product) }.to change { CardProduct.count }.by(1)
    end
  end
end
