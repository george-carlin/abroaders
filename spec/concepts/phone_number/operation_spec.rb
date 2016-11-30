require 'rails_helper'

describe PhoneNumber::Create do
  let(:account) { create(:account, onboarding_state: :phone_number) }

  example '.normalize' do
    expect(described_class.normalize('123412345')).to eq '123412345'
    expect(described_class.normalize('123-41a23 4 -+AIWJER 5')).to eq '123412345'
  end

  example 'valid save' do
    res, op = [nil, nil]

    expect do
      res, op = described_class.run(
        phone_number: { number: '(123) 5678-555' },
        current_account: account,
      )
    end.to send_email.to(ENV['MAILPARSER_SURVEY_COMPLETE'])
      .with_subject("App Profile Complete - #{account.email}")

    expect(res).to be true

    phone_number = op.model
    expect(phone_number.number).to eq '(123) 5678-555'
    expect(phone_number.normalized_number).to eq '1235678555'
    expect(account.reload.onboarding_state).to eq 'complete'
  end

  example 'valid save with trailing whitespace' do
    res, op = described_class.run(
      phone_number: { number: ' (123) 5678-555 ' },
      current_account: account,
    )
    expect(res).to be true

    phone_number = op.model
    expect(phone_number.number).to eq '(123) 5678-555'
    expect(phone_number.normalized_number).to eq '1235678555'
    expect(account.reload.onboarding_state).to eq 'complete'
  end

  example 'invalid save' do
    res, = described_class.run(
      phone_number: {
        number: '   ',
      },
      current_account: account,
    )
    expect(res).to be false

    account.reload
    expect(account.phone_number).to be nil
    expect(account.onboarding_state).to eq 'phone_number'
  end
end
