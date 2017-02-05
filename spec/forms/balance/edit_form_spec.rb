require 'rails_helper'

RSpec.describe Balance::EditForm do
  let(:balance) { Struct.new(:value, :currency_id).new }

  def errors_for(key, value)
    form = described_class.new(balance)
    form.validate(key => value)
    form.errors[key]
  end

  describe 'value' do
    it 'must be present' do
      expect(errors_for(:value, nil)).to include 'is missing'
    end

    it 'must be >= 0' do
      expect(errors_for(:value, -1)).to \
        include('must be greater than or equal to 0')
      expect(errors_for(:value, -1)).to \
        include("must be less than or equal to #{POSTGRESQL_MAX_INT_VALUE}")
      expect(errors_for(:value, 0)).to be_empty
    end
  end
end
