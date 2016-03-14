require 'rails_helper'

describe Passenger do
  let(:passenger) { described_class.new }

  describe "#full_name" do
    it "returns the full name" do
      expect(passenger.full_name).to eq ""
      passenger.first_name = "Dave"
      expect(passenger.full_name).to eq "Dave"
      passenger.last_name = "Smith"
      expect(passenger.full_name).to eq "Dave Smith"
      passenger.middle_names = "James Edgar"
      expect(passenger.full_name).to eq "Dave James Edgar Smith"
    end
  end

  describe "before save" do
    let(:passenger) { build(:passenger) }

    %w[first_name middle_names last_name phone_number].each do |attr|
      it "strips trailing whitespace from #{attr}" do
        passenger.send :"#{attr}=", "  string    "
        passenger.save!
        expect(passenger.send(attr)).to eq "string"
      end
    end
  end

  pending "it says whether or not the user has added any travel plans"
end
