require 'rails_helper'

describe Survey do

  let(:survey) { described_class.new }

  describe "#full_name" do
    it "returns the full name" do
      expect(survey.full_name).to eq ""
      survey.first_name = "Dave"
      expect(survey.full_name).to eq "Dave"
      survey.last_name = "Smith"
      expect(survey.full_name).to eq "Dave Smith"
      survey.middle_names = "James Edgar"
      expect(survey.full_name).to eq "Dave James Edgar Smith"
    end
  end

  describe "before save" do
    let(:survey) { build(:survey) }

    %w[first_name middle_names last_name phone_number].each do |attr|
      it "strips trailing whitespace from #{attr}" do
        survey.send :"#{attr}=", "   string    "
        survey.save!
        expect(survey.send(attr)).to eq "string"
      end
    end
  end

  pending "it says whether or not the user has added any travel plans"
end
