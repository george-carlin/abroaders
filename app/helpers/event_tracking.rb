module EventTracking

  def track_intercom_event(event_name)
    IntercomJobs::TrackEvent.perform_later(
      email:      current_account.email,
      event_name: event_name,
    )
  end

end
