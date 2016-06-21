require "rails_helper"

module IntercomJobs
  describe CreateUser do
    it "creates a user on Intercom" do
      time    = Time.parse("2016-05-03 12:41 PM UTC")
      email   = "testtesttest@example.com"
      # .to_s(:db) is necessary here or the suite will fail on codeship when the VCR
      # cassette has been recorded locally in a timezone other than UTC
      account = create(:account, email: email, created_at: time.utc.to_s(:db))
      account.main_person.update_attributes!(first_name: "Dave")

      new_user = nil
      VCR.use_cassette("intercom_jobs.create_user") do
        described_class.perform_now(account_id: account.id)

        expect do
          new_user = INTERCOM.users.find(email: email)
        end.not_to raise_error
      end

      expect(new_user.email).to eq "testtesttest@example.com"
      expect(new_user.name).to eq "Dave"
      expect(new_user.signed_up_at.to_i).to eq time.to_i
    end
  end
end
