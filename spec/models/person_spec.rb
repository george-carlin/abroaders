require 'rails_helper'

describe Person do
  let(:person) { described_class.new }

  describe "before save" do
    let(:person) { build(:person) }

    it "strips trailing whitespace from first_name" do
      person.first_name= "    string    "
      person.save!
      expect(person.first_name).to eq "string"
    end
  end

end
