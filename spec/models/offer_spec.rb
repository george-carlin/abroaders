require 'rails_helper'

RSpec.describe Offer do
  specify '"condition" is "on minimum spend" by default"' do
    expect(Offer.new.condition).to eq 'on_minimum_spend'
  end
end
