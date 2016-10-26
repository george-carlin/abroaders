shared_context "set admin email ENV var" do
  before do
    @real_env_email = ENV["ADMIN_EMAIL"]
    ENV["ADMIN_EMAIL"] = admin_email
    visit new_account_registration_path
  end
  after { ENV["ADMIN_EMAIL"] = @real_env_email }
  let(:admin_email) { "test@example.com" }
end

shared_examples "don't send any emails" do
  it "doesn't send any emails" do
    expect do
      submit_form
      send_all_enqueued_emails!
    end.not_to change { ApplicationMailer.deliveries.length }
  end
end
