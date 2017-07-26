require 'rails_helper'

RSpec.describe PhoneNumber::Normalize do
  example '.normalize' do
    expect(described_class.('123412345')).to eq '123412345'
    expect(described_class.('123-41a23 4 -+AIWJER 5')).to eq '123412345'
  end

  # Be generous - just ignore everything that's not a digit.
  # If there are 10 digits, add a '1' on the beginning.
  # If there are 11 digits, the first digit must be a '1' or it's invalid.

  example '.us_normalize' do
    op = described_class::US

    expect(op.('')).to be_nil
    expect(op.(nil)).to be_nil

    # Not long enough:
    expect(op.('111')).to be_nil
    expect(op.('111 543 543')).to be_nil
    expect(op.('(111) 543-543')).to be_nil
    # ignore all non-digits:
    expect(op.('    (A1B!+=(@11) 543-543    ')).to be_nil

    # Too long:
    expect(op.('23487629855')).to be_nil
    expect(op.('323487629855')).to be_nil
    expect(op.('123487629855')).to be_nil
    expect(op.('111 543 543')).to be_nil
    expect(op.('(111) 543-543')).to be_nil
    # ignore all non-digits:
    expect(op.("    9A4 7!3$82^9  \n16&91    ")).to be_nil
    expect(op.("    12@47\t!38\n2$91 691    ")).to be_nil

    # Unchanged:
    expect(op.('13453456785')).to eq '13453456785'

    # Add the '1':
    expect(op.('3453456785')).to eq '13453456785'
    expect(op.('1453456785')).to eq '11453456785'

    # Ignore non-digits:
    expect(op.('  13A$%453$%&$HK 45@$ 6785   ')).to eq '13453456785'
    expect(op.('  34A$%53456%$£  7AWER85   ')).to eq '13453456785'
  end
end
