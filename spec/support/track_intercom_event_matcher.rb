RSpec::Matchers.define :track_intercom_event do |*event_names|
  include ActiveJob::TestHelper

  supports_block_expectations

  match do |action|
    raise "must specify email with .for_email" unless @email

    @event_names = event_names

    action.call

    @jobs = enqueued_track_event_jobs

    @jobs.length == @event_names.length && \
      @jobs.all? { |job| job[:args][0]["email"] == @email }
        @event_names.sort == @jobs.map { |job| job[:args][0]["event_name"] }.sort
  end

  chain :for_email do |email|
    @email = email
  end

  # There might be some cases I've missed that this matcher won't cover (i.e.
  # you might get false negatives or false positives).  but it's not worth the
  # effort to cover those cases for now. If you get the 'unknown  error'
  # message, you might want to update the matcher.
  failure_message do
    msg = "expected that "
    if @event_names.many?
      msg << "an Intercom event called #{@event_names[0]} "
    else
      msg << "Intercom events called #{@event_names.to_sentence} "
    end
    msg << "would be queued for the user with email '#{@email}', but "

    if @jobs.length == 0
      return msg << "no events were queued"
    end

    msg << "an error occurred. The queued events were:\n"

    @jobs.each do |job|
      args = job[:args][0]
      msg << "\n  event name: #{args["event_name"]}, email: #{args["email"]}"
    end

    msg
  end

  private

  def enqueued_track_event_jobs
    enqueued_jobs.select { |job| job[:job] == IntercomJobs::TrackEvent }
  end

end

RSpec::Matchers.alias_matcher :track_intercom_events, :track_intercom_event
