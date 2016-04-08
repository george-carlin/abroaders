require 'rails_helper'

describe Passenger do
  let(:passenger) { described_class.new }

  describe "before save" do
    let(:passenger) { build(:passenger) }

    it "strips trailing whitespace from first_name" do
      passenger.first_name= "    string    "
      passenger.save!
      expect(passenger.first_name).to eq "string"
    end
  end

end
