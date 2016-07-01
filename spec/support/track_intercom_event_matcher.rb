RSpec::Matchers.define :track_intercom_event do |event_name|
  include ActiveJob::TestHelper

  supports_block_expectations

  match do |action|
    raise "must specify email with .for_email" unless @email

    @event_name = event_name

    @job_count_before = enqueued_track_event_jobs.size
    action.call
    @job_count_after  = enqueued_track_event_jobs.size

    # Don't check that the difference is exactly +1, because the action might
    # have enqueued other jobs e.g. to send email.
    return false unless @job_count_after > @job_count_before

    # Right now we don't need to handle this case, but that may change later.
    if (@job_count_after - @job_count_after) > 1
      raise "more than one TrackEvent job queued"
    end

    @job = enqueued_track_event_jobs.first

    args["event_name"] == @event_name && args["email"] == @email
  end

  chain :for_email do |email|
    @email = email
  end

  # There might be some cases I've missed that this matcher won't cover (i.e.
  # you might get false negatives or false positives).  but it's not worth the
  # effort to cover those cases for now. If you get the 'unknown  error'
  # message, you might want to update the matcher.
  failure_message do
    msg = "expected that an Intercom event called '#{@event_name}' would be "\
          "queued for the user with email '#{@email}', but "

    if !@job
      msg << "no background job was queued"
    elsif @job[:job] != IntercomJobs::TrackEvent
      msg << "an unknown error occurred"
    elsif wrong_event_name?
      msg << "the actual queued event was called '#{args["event_name"]}'"
    elsif wrong_email?
      msg << "the actual email address was '#{@email}'"
    else
      msg << "but an unknown error occurred"
    end

    msg
  end

  private

  def args
    @job[:args][0]
  end

  def wrong_event_name?
    args["event_name"] && args["event_name"] != @event_name
  end

  def wrong_email?
    args["email"] && args["email"] != @email
  end

  def enqueued_track_event_jobs
    enqueued_jobs.select { |job| job[:job] == IntercomJobs::TrackEvent }
  end

end
