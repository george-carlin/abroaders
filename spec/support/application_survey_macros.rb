module ApplicationSurveyMacros
  # The apply 'button' is actually a link styled like a button

  def self.included(base)
    base.include DatepickerMacros
    base.instance_eval do
      let(:decline_btn)   { 'No Thanks' }
      let(:denied_btn)    { 'My application was denied' }
      let(:i_applied_btn) { 'I applied' }
      let(:approved_btn)  { 'I was approved' }
      let(:pending_btn)   { "I'm waiting to hear back" }
      let(:approved_at)   { 'card_opened_at' }
    end
  end

  def have_apply_btn(card, present = true)
    meth = present ? :have_link : :have_no_link
    send(meth, 'Apply', href: apply_recommendation_path(card))
  end

  def decline_reason_wrapper
    find('#card_decline_reason').find(:xpath, '..')
  end

  def set_approved_at_to(date)
    raise "error: approved at must be today or in the past" if date > Time.zone.today

    set_datepicker_field('#' << approved_at, to: date)
  end
end
