require 'rails_helper'

describe PhoneNumber::Operations::Create do
  let(:account) { create(:account) }

  example 'valid save' do
    result = described_class.(
      { phone_number: { number: '(123) 5678-555' } },
      account: account,
    )

    expect(result.success?).to be true

    phone_number = result['model']
    expect(phone_number.number).to eq '(123) 5678-555'
    expect(phone_number.normalized_number).to eq '1235678555'
  end

  example 'valid save with trailing whitespace' do
    result = described_class.(
      { phone_number: { number: ' (123) 5678-555 ' } },
      account: account,
    )
    expect(result.success?).to be true

    phone_number = result['model']
    expect(phone_number.number).to eq '(123) 5678-555'
    expect(phone_number.normalized_number).to eq '1235678555'
  end

  example 'invalid save' do
    result = described_class.(
      { phone_number: { number: '   ' } },
      account: account,
    )
    expect(result.success?).to be false
  end
end
