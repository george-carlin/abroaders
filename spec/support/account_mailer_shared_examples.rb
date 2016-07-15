shared_context "set erik's email ENV var" do
  before do
    @real_env_email = ENV["ERIKS_EMAIL"]
    ENV["ERIKS_EMAIL"] = eriks_email
    visit new_account_registration_path
  end
  after { ENV["ERIKS_EMAIL"] = @real_env_email }
  let(:eriks_email) { "test@example.com" }
end

shared_examples "send survey complete email to admin" do
  it "sends a 'survey complete' admin notification" do
    expect{submit_form}.to change { enqueued_jobs.size }

    expect do
      perform_enqueued_jobs { ActionMailer::DeliveryJob.perform_now(*enqueued_jobs.first[:args]) }
    end.to change {(ApplicationMailer.deliveries.length)}.by(1)

    email = ApplicationMailer.deliveries.last
    expect(email.subject).to eq "App Profile Complete - #{account.email}"
    expect(email.to).to match_array [eriks_email]
  end
end

shared_examples "don't send any emails" do
  it "doesn't send any emails" do
    expect do
      submit_form
      send_all_enqueued_emails!
    end.not_to change{ApplicationMailer.deliveries.length}
  end
end
