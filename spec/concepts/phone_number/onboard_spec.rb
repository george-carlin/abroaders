require 'rails_helper'

RSpec.describe PhoneNumber::Onboard do
  let(:account) { create_account(onboarding_state: :phone_number) }

  example 'valid save' do
    result = nil
    expect do
      result = described_class.(
        { account: { phone_number: '(123) 5678-555' } },
        'account' => account,
      )
    end.to send_email.to(ENV['MAILPARSER_SURVEY_COMPLETE'])
      .with_subject("App Profile Complete - #{account.email}")

    expect(result.success?).to be true

    expect(account).to eq result['model']

    expect(result['model'].phone_number).to eq '(123) 5678-555'
    expect(result['model'].phone_number_normalized).to eq '1235678555'
    expect(result['model'].onboarding_state).to eq 'complete'
  end

  example 'valid save with trailing whitespace' do
    result = described_class.(
      { account: { phone_number: ' (123) 5678-555 ' } },
      'account' => account,
    )
    expect(result.success?).to be true

    expect(account).to eq result['model']

    expect(result['model'].phone_number).to eq '(123) 5678-555'
    expect(result['model'].phone_number_normalized).to eq '1235678555'
    expect(result['model'].onboarding_state).to eq 'complete'
  end

  example 'invalid save' do
    result = described_class.(
      { account: { phone_number: '   ' } },
      'account' => account,
    )
    expect(result.success?).to be false

    expect(account).to eq result['model']

    expect(result['model'].phone_number).to be nil
    expect(result['model'].onboarding_state).to eq 'phone_number'
  end
end
