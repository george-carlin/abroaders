class AccountTypeForm < ApplicationForm

  private

  def track_intercom_event!
    IntercomJobs::TrackEvent.perform_later(
      email:      account.email,
      event_name: "onboarded-account-type",
    )
  end
end
