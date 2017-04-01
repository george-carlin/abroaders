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

    example 'recursive with nested hashes' do
      input = {
        'firstName' => 'George',
        'homeAddress' => {
          'streetName' => '1 Main St.',
          'town' => 'London',
          'country' => {
            'name' => 'England',
            'isoCode' => 'GB',
          },
        },
      }

      # non-recursive:
      expect(described_class.underscore_keys(input)).to eq(
        'first_name' => 'George',
        'home_address' => {
          'streetName' => '1 Main St.',
          'town' => 'London',
          'country' => {
            'name' => 'England',
            'isoCode' => 'GB',
          },
        },
      )

      # recursive:
      expect(described_class.underscore_keys(input, true)).to eq(
        'first_name' => 'George',
        'home_address' => {
          'street_name' => '1 Main St.',
          'town' => 'London',
          'country' => {
            'name' => 'England',
            'iso_code' => 'GB',
          },
        },
      )
    end

    example 'recursive with nested arrays of hashes' do
      input  = { 'foo' => [{ 'fooBar' => 1 }, { 'fizzBuzz' => 2 }] }

      # non-recursive:
      result = described_class.underscore_keys(input)
      expect(result).to eq(
        'foo' => [{ 'fooBar' => 1 }, { 'fizzBuzz' => 2 }],
      )

      # recursive:
      result = described_class.underscore_keys(input, true)
      expect(result).to eq(
        'foo' => [{ 'foo_bar' => 1 }, { 'fizz_buzz' => 2 }],
      )

      # recursive when nested arrays contain nested hashes:
      input  = { 'foo' => [{ 'fooBar' => { 'fizzBuzz' => 2 } }] }
      result = described_class.underscore_keys(input, true)
      expect(result).to eq(
        'foo' => [{ 'foo_bar' => { 'fizz_buzz' => 2 } }],
      )
    end

    it 'makes deep copies' do
      # nested hashes:
      input = {
        'firstName' => 'George',
        'homeAddress' => { 'streetName' => '1 Main St.', 'town' => 'London' },
      }

      result = described_class.underscore_keys(input)
      result['home_address']['streetName'] = '2 High St.'
      expect(input['homeAddress']['streetName']).to eq '1 Main St.'

      # nested arrays:
      input  = { 'foo' => [{ 'fooBar' => 1 }, { 'fizzBuzz' => 2 }] }
      result = described_class.underscore_keys(input)
      result['foo'][0]['fooBar'] = 2
      expect(input['foo'][0]['fooBar']).to eq 1
    end
  end
end
