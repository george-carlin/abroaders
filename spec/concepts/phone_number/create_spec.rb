require 'rails_helper'

RSpec.describe PhoneNumber::Create do
  let(:account) { create_account }

  example 'valid save' do
    result = described_class.(
      { account: { phone_number: '(123) 5678-555' } },
      current_account: account,
    )

    expect(result.success?).to be true

    expect(account).to eq result['model']
    expect(result['model'].phone_number).to eq '(123) 5678-555'
    expect(result['model'].phone_number_normalized).to eq '1235678555'
    expect(result['model'].phone_number_us_normalized).to eq '11235678555'
  end

  example 'valid save with trailing whitespace' do
    result = described_class.(
      { account: { phone_number: ' (123) 5678-555 ' } },
      current_account: account,
    )
    expect(result.success?).to be true

    expect(account).to eq result['model']
    expect(result['model'].phone_number).to eq '(123) 5678-555'
    expect(result['model'].phone_number_normalized).to eq '1235678555'
    expect(result['model'].phone_number_us_normalized).to eq '11235678555'
  end

  example 'valid save with +1 country code' do
    result = described_class.(
      { account: { phone_number: '+1 (123) 5678-555 ' } },
      current_account: account,
    )
    expect(result.success?).to be true

    expect(account).to eq result['model']
    expect(result['model'].phone_number).to eq '+1 (123) 5678-555'
    expect(result['model'].phone_number_normalized).to eq '11235678555'
    expect(result['model'].phone_number_us_normalized).to eq '111235678555'
  end

  # see specs for PhoneNumber::Normalize for full testing of normalization

  example 'valid save with non-US number' do
    result = described_class.(
      { account: { phone_number: '+44 123 25678-555 ' } },
      current_account: account,
    )
    expect(result.success?).to be true

    expect(account).to eq result['model']
    expect(result['model'].phone_number).to eq '+44 123 25678-555'
    expect(result['model'].phone_number_normalized).to eq '4412325678555'
    expect(result['model'].phone_number_us_normalized).to be_nil
  end

  example 'invalid save' do
    result = described_class.(
      { account: { phone_number: '   ' } },
      current_account: account,
    )
    expect(result.success?).to be false
  end
end
