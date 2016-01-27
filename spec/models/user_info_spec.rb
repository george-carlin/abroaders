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

  describe "before save" do
    before do
      info.user = create(:user)
      info.attributes = attributes_for(:user_info)
    end

    %w[first_name middle_names last_name phone_number].each do |attr|
      it "strips trailing whitespace from #{attr}" do
        info.send :"#{attr}=", "   string    "
        info.save!
        expect(info.send(attr)).to eq "string"
      end
    end
  end
end
