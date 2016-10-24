require "rails_helper"

module IntercomJobs
  describe TrackEvent do
    let(:email) { "intercom_test.track_event@example.com" }

    before do
      VCR.use_cassette("intercom_jobs_track_event_setup") do
        @user = INTERCOM.users.create(
          email: email,
          name:  "Someone",
          signed_up_at: Time.now.to_i,
        )
      end
    end

    after do
      VCR.use_cassette("intercom_jobs_track_event_teardown") do
        INTERCOM.users.delete(@user)
      end
    end

    it "tracks an event on Intercom for the given user" do
      event_name = "my_awesome_event"

      VCR.use_cassette "intercom_jobs_track_event" do
        described_class.perform_now(
          event_name: event_name,
          email:      email,
          created_at: Time.now.to_i,
        )

        response = HTTParty.get(
          "https://api.intercom.io/events?type=user",
          body: {
            intercom_user_id: @user.id,
          },
          basic_auth: {
            username: ENV["INTERCOM_APP_ID"],
            password: ENV["INTERCOM_API_KEY"],
          },
          headers: {
            "Accept" => "application/json",
          },
        ).parsed_response

        expect(response["events"].last["event_name"]).to eq event_name
      end
    end
  end
end
