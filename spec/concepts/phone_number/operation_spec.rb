require 'rails_helper'

describe PhoneNumber::Create do
  let(:account) { create(:account) }

  example '.normalize' do
    expect(described_class.normalize('123412345')).to eq '123412345'
    expect(described_class.normalize('123-41a23 4 -+AIWJER 5')).to eq '123412345'
  end

  example 'valid save' do
    res, op = described_class.run(
      phone_number: {
        number: ' (123) 5678-555 ',
      },
      current_account: account,
    )
    expect(res).to be true

    phone_number = op.model
    expect(phone_number.number).to eq '(123) 5678-555'
    expect(phone_number.normalized_number).to eq '1235678555'
  end

  example 'invalid save' do
    res, = described_class.run(
      phone_number: {
        number: '   ',
      },
      current_account: account,
    )
    expect(res).to be false
  end
end
