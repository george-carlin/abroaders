require 'rails_helper'

# Destination uses STI. This spec file tests Destination and all its
# subclasses.  If it gets too long we can split it later.
RSpec.describe Destination do
  let(:region)  { Region.all.first }
  let(:country) { Country.new(region_code: region.code) }
  let(:city)    { City.new }
  let(:airport) { Airport.new }

  example "#region" do
    city.parent    = country
    airport.parent = city

    expect(country.region).to eq region
    expect(city.region).to eq region
    expect(airport.region).to eq region
  end

  example "#region when there is no region in the hierarchy" do
    airport.parent = city
    expect(airport.region).to be_nil
  end

  example "##country? etc predicate methods" do
    expect(country.country?).to be true
    expect(city.country?).to be false
    expect(airport.country?).to be false

    expect(country.city?).to be false
    expect(city.city?).to be true
    expect(airport.city?).to be false

    expect(country.airport?).to be false
    expect(city.airport?).to be false
    expect(airport.airport?).to be true
  end

  specify "Airport parent must be a City" do
    def errors
      airport.tap(&:validate).errors[:parent]
    end

    err_msg = "must be a city"

    airport.parent = nil
    expect(errors).not_to include err_msg
    airport.parent = airport
    expect(errors).to include err_msg
    airport.parent = city
    expect(errors).not_to include err_msg
    airport.parent = country
    expect(errors).to include err_msg
  end
end
