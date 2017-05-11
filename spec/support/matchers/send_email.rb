RSpec::Matchers.define :send_email do
  supports_block_expectations

  match do |action|
    @enqueued_before = enqueued_jobs.size
    action.call
    @enqueued_after = enqueued_jobs.size

    # Don't check that the difference is exactly +1, because the action might
    # have enqueued other jobs as well as the mailer job
    result = @enqueued_after > @enqueued_before

    if result && (@to || @subj)
      @deliveries_before = ApplicationMailer.deliveries.length
      send_all_enqueued_emails!
      @deliveries_after = ApplicationMailer.deliveries.length

      result &&= @deliveries_after > @deliveries_before

      if result
        @email = ApplicationMailer.deliveries.last
        result &&= @email.to.include?(@to) if @to
        result &&= @email.subject == @subj if @subj
      end
    end

    result
  end

  failure_message do
    msg = "expected that an email would be sent"

    msg << " to #{@to}" if @to
    msg << " with subject '#{@subj}'" if @subj

    msg << " but"

    if @enqueued_after <= @enqueued_before
      msg << " no email job was queued"
    elsif @to || @subj
      if @deliveries_after <= @deliveries_before
        msg << " no email was sent"
      else
        errors = []
        errors << " it was sent to #{@email.to.to_sentence}" if @to
        errors << " the subject was '#{@subj}'" if @subj
        msg << errors.join(" and ")
      end
    else
      msg << " an unknown error occurred"
    end
    msg
  end

  chain :to do |address|
    @to = address
  end

  chain :with_subject do |subj|
    @subj = subj
  end
end
