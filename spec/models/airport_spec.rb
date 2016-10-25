require 'rails_helper'

describe Airport do
  describe '#full_name' do
    example 'airport name includes city name' do
      city    = City.new(name: 'Frankfurt')
      airport = Airport.new(name: 'Frankfurt Main', code: 'FRA', city: city)
      expect(airport.full_name).to eq 'Frankfurt Main (FRA)'
    end

    example "airport name doesn't include city name" do
      city    = City.new(name: 'London')
      airport = Airport.new(name: 'Heathrow', code: 'LHR', city: city)
      expect(airport.full_name).to eq 'London Heathrow (LHR)'
    end
  end
end
