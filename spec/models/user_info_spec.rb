require 'rails_helper'

describe UserInfo do

  let(:info) { described_class.new }

  describe "#full_name" do
    it "returns the full name" do
      expect(info.full_name).to eq ""
      info.first_name = "Dave"
      expect(info.full_name).to eq "Dave"
      info.last_name = "Smith"
      expect(info.full_name).to eq "Dave Smith"
      info.middle_names = "James Edgar"
      expect(info.full_name).to eq "Dave James Edgar Smith"
    end
  end
end
