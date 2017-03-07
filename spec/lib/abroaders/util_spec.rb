require 'abroaders/util'

RSpec.describe Abroaders::Util do
  describe '.underscore_keys' do
    example 'passed a hash with symbol keys' do
      result = described_class.underscore_keys(age: 26, firstName: 'George')
      expect(result).to eq('age' => 26, 'first_name' => 'George')
    end

    example 'passed a hash with string keys' do
      result = described_class.underscore_keys('age' => 26, 'firstName' => 'George')
      expect(result).to eq('age' => 26, 'first_name' => 'George')
    end

    example 'recursive' do
      input = {
        'firstName' => 'George',
        'homeAddress' => { 'streetName' => '1 Main St.', 'town' => 'London' },
      }

      # non-recursive:
      expect(described_class.underscore_keys(input)).to eq(
        'first_name' => 'George',
        'home_address' => { 'streetName' => '1 Main St.', 'town' => 'London' },
      )

      # recursive:
      expect(described_class.underscore_keys(input, true)).to eq(
        'first_name' => 'George',
        'home_address' => { 'street_name' => '1 Main St.', 'town' => 'London' },
      )
    end

    it 'makes deep copies' do
      input = {
        'firstName' => 'George',
        'homeAddress' => { 'streetName' => '1 Main St.', 'town' => 'London' },
      }

      result = described_class.underscore_keys(input)
      result['home_address']['streetName'] = '2 High St.'
      expect(input['homeAddress']['streetName']).to eq '1 Main St.'
    end
  end
end
