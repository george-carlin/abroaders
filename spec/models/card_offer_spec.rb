require 'rails_helper'

describe CardOffer do
  describe "validations" do
    %i[cost points_awarded spend days].each do |attr|
      it do
        is_expected.to validate_numericality_of(attr)
                          .is_greater_than_or_equal_to(0)
                          .is_less_than_or_equal_to(POSTGRESQL_MAX_INT_VALUE)
      end
    end
  end
end
