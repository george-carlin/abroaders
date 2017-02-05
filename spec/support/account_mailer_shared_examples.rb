RSpec.shared_examples "don't send any emails" do
  it "doesn't send any emails" do
    expect do
      submit_form
      send_all_enqueued_emails!
    end.not_to change { ApplicationMailer.deliveries.length }
  end
end
