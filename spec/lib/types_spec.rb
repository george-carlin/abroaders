require 'rails_helper'

RSpec.describe Types do
  describe 'Form::AmericanDate' do
    let(:date) { Date.parse("2016-05-08") }

    let(:type) { Types::Form::AmericanDate }


    context "when passed a String" do
      it "parses the date in format mm/dd/yyyy" do
        expect(type['05/08/2016']).to eq date
      end
    end

    context 'when passed a Date' do
      it 'uses it as-is' do
        expect(type[date]).to eq date
      end
    end
  end
end
