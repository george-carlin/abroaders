require APP_ROOT.join('lib', 'types')

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

  it 'StrippedString' do
    type = Types::StrippedString
    expect(type[nil]).to eq ''
    expect(type['']).to eq ''
    expect(type['   ']).to eq ''
    expect(type['a']).to eq 'a'
    expect(type[' a ']).to eq 'a'
  end

  # accepts blank strings, else raises an error
  it 'BlankString' do
    type = Types::BlankString
    expect(type['']).to eq ''
    expect(type['   ']).to eq ''
    expect(type.try('a').success?).to be false
    expect(type[nil]).to eq ''

    optional = type.optional
    expect(optional['']).to eq ''
    expect(optional['   ']).to eq ''
    expect(optional.try('a').success?).to be false
    expect(optional[nil]).to be nil

    sum = Types::StrippedString.constrained(format: /george/) | type.optional
    expect(sum['george']).to eq 'george'
    expect(sum['  george  ']).to eq 'george'
    expect(sum.try('  invalid  ').success?).to be false
    expect(sum['']).to eq ''
    expect(sum['  ']).to eq ''
    expect(sum[nil]).to be nil
  end
end
