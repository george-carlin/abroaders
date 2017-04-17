require 'rails_helper'

RSpec.describe PhoneNumber::Create do
  let(:account) { create(:account) }

  example 'valid save' do
    result = described_class.(
      { account: { phone_number: '(123) 5678-555' } },
      account: account,
    )

    expect(result.success?).to be true

    expect(account).to eq result['model']
    expect(result['model'].phone_number).to eq '(123) 5678-555'
    expect(result['model'].phone_number_normalized).to eq '1235678555'
  end

  example 'valid save with trailing whitespace' do
    result = described_class.(
      { account: { phone_number: ' (123) 5678-555 ' } },
      account: account,
    )
    expect(result.success?).to be true

    expect(account).to eq result['model']
    expect(result['model'].phone_number).to eq '(123) 5678-555'
    expect(result['model'].phone_number_normalized).to eq '1235678555'
  end

  example 'invalid save' do
    result = described_class.(
      { account: { phone_number: '   ' } },
      account: account,
    )
    expect(result.success?).to be false
  end
end
