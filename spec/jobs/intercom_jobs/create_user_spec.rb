require "rails_helper"

module IntercomJobs
  RSpec.describe CreateUser do
    it 'creates a user on Intercom' do
      time  = Time.now
      email = 'testtesttest@example.com'

      intercom_user_service = double
      allow(INTERCOM).to receive(:users).and_return(intercom_user_service)

      expect(intercom_user_service).to receive(:create).with(
        email:        email,
        name:         'Dave',
        signed_up_at: time.to_i,
      )

      described_class.perform_now(
        'email'        => email,
        'name'         => 'Dave',
        'signed_up_at' => time.to_i,
      )
    end
  end
end
