require 'rails_helper'

RSpec.describe Password::SendResetInstructions, :auth do
  let(:email) { 'test@example.com' }
  before { create_account(email: email) }
  let(:op) { described_class }

  example 'with an email that exists' do
    result = nil
    expect do
      result = op.(account: { email: email })
    end.to change { ApplicationMailer.deliveries.length }.by(1)
    expect(ApplicationMailer.deliveries.last.to).to include(email)
    expect(ApplicationMailer.deliveries.last.body).to include(result['token'])

    # expect do
    #   result = op.(account: { email: email })
    # end.to send_email.to(email)# .with_subject
    expect(result.success?).to be true

    account = result['model']
    expect(account).to be_persisted
    expect(account.email).to eq email
    expect(account.reset_password_token).not_to be_nil
    expect(account.reset_password_sent_at).to be_within(5.seconds).of(Time.now.utc)
  end

  example "with an email that doesn't exist" do
    result = nil
    expect { result = op.(account: { email: "x#{email}" }) }.not_to send_email
    expect(result.success?).to be false

    account = result['model']
    expect(account).not_to be_persisted
    expect(account.email).to eq "x#{email}"
    expect(account.errors[:email]).to eq ['not found']
    expect(account.reset_password_token).to be nil
    expect(account.reset_password_sent_at).to be nil
  end

  example 'blank email' do
    expect do
      result = op.(account: { email: '' })
      expect(result.success?).to be false
    end.not_to change { ApplicationMailer.deliveries.length }
  end

  example 'email with trailing whitespace' do
    expect do
      result = op.(account: { email: "  #{email}   " })
      expect(result.success?).to be true
    end.to change { ApplicationMailer.deliveries.length }.by(1)
  end
end
