require 'rails_helper'

describe PhoneNumber::Operations::Onboard do
  let(:account) { create(:account, onboarding_state: :phone_number) }

  example 'valid save' do
    result = nil
    expect do
      result = described_class.(
        { phone_number: { number: '(123) 5678-555' } },
        'account' => account,
      )
    end.to send_email.to(ENV['MAILPARSER_SURVEY_COMPLETE'])
      .with_subject("App Profile Complete - #{account.email}")

    expect(result.success?).to be true

    phone_number = result['model']
    expect(phone_number.number).to eq '(123) 5678-555'
    expect(phone_number.normalized_number).to eq '1235678555'
    expect(account.reload.onboarding_state).to eq 'complete'
  end

  example 'valid save with trailing whitespace' do
    result = described_class.(
      { phone_number: { number: ' (123) 5678-555 ' } },
      'account' => account,
    )
    expect(result.success?).to be true

    phone_number = result['model']
    expect(phone_number.number).to eq '(123) 5678-555'
    expect(phone_number.normalized_number).to eq '1235678555'
    expect(account.reload.onboarding_state).to eq 'complete'
  end

  example 'invalid save' do
    result = described_class.(
      { phone_number: { number: '   ' } },
      'account' => account,
    )
    expect(result.success?).to be false

    account.reload
    expect(account.phone_number).to be nil
    expect(account.onboarding_state).to eq 'phone_number'
  end
end
