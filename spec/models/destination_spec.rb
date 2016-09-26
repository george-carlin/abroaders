require 'rails_helper'

# Destination uses STI. This spec file tests Destination and all its
# subclasses.  If it gets too long we can split it later.
describe Destination do

  let(:region)  { Region.new }
  let(:country) { Country.new }
  let(:city)    { City.new }
  let(:airport) { Airport.new }

  let(:type_err_msg) { "type is invalid" }

  example "Region#region" do
    # it returns itself:
    expect(region.region).to eq region
  end

  example "#region for non-Region subclasses" do
    country.parent = region
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

  example "#region?, #country? etc predicate methods" do
    expect(region.region?).to be true
    expect(country.region?).to be false
    expect(city.region?).to be false
    expect(airport.region?).to be false

    expect(region.country?).to be false
    expect(country.country?).to be true
    expect(city.country?).to be false
    expect(airport.country?).to be false

    expect(region.city?).to be false
    expect(country.city?).to be false
    expect(city.city?).to be true
    expect(airport.city?).to be false

    expect(region.airport?).to be false
    expect(country.airport?).to be false
    expect(city.airport?).to be false
    expect(airport.airport?).to be true
  end

  specify "Airport parent must be a City or Country" do
    def errors
      airport.tap(&:validate).errors[:parent]
    end

    airport.parent = nil
    expect(errors).not_to include type_err_msg
    airport.parent = airport
    expect(errors).to include type_err_msg
    airport.parent = city
    expect(errors).not_to include type_err_msg
    airport.parent = country
    expect(errors).not_to include type_err_msg
    airport.parent = region
    expect(errors).to include type_err_msg
  end

end
