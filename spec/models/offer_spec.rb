require 'rails_helper'

describe Offer do
  let(:offer) { described_class.new }

  describe "validations" do
    %i[cost points_awarded spend days].each do |attr|
      it do
        is_expected.to validate_numericality_of(attr)
                          .is_greater_than_or_equal_to(0)
                          .is_less_than_or_equal_to(POSTGRESQL_MAX_INT_VALUE)
      end
    end
  end

  describe "#condition" do
    it "is 'on minimum spend' by default" do
      expect(offer).to be_on_minimum_spend
    end
  end

end
