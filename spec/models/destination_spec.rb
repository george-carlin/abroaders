require 'rails_helper'

describe Destination do

  describe "#region" do
    context "when the destination is a region" do
      it "returns itself" do
        dest = Destination.region.new
        expect(dest.region).to eq dest
      end
    end

    context "when the destination is not a region" do
      it "returns the parent region" do
        region  = Destination.region.new
        country = Destination.country.new(parent: region)
        state   = Destination.state.new(parent: country)
        city    = Destination.city.new(parent: state)
        airport = Destination.airport.new(parent: city)

        expect(country.region).to eq region
        expect(state.region).to eq region
        expect(city.region).to eq region
        expect(airport.region).to eq region
      end
    end

    context "when there is no region in the hierarchy" do
      it "returns nil" do
        city    = Destination.city.new
        airport = Destination.airport.new(parent: city)
        expect(airport.region).to be_nil
      end
    end
  end

  pending "validate parent hierarchy follows the right order; airport.parent can't be an airport, city.parent can't be a state etc"

end
