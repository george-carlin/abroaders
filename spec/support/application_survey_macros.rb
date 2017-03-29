module ApplicationSurveyMacros
  # The apply 'button' is actually a link styled like a button

  def self.included(base)
    base.include DatepickerMacros
    base.instance_eval do
      # some of these buttons have different text for different survey stages,
      # so you'll have to override these let variables where appropriate:
      let(:approved_at)      { 'card_opened_on' }
      let(:decline_btn)      { 'No Thanks' }
      let(:i_applied_btn)    { 'I applied' }
      let(:i_heard_back_btn) { 'I heard back from the bank' }
      let(:pending_btn)      { "I'm waiting to hear back" }
      let(:approved_btn) { 'I was approved' }
      let(:denied_btn)   { 'My application was denied' }
    end
  end

  def i_called_btn(rec)
    "I called #{rec.product.bank.name}"
  end

  # apply btn is different from the others because it's actually a link
  # to another page (styled like a button) rather than a button that changes
  # something on the current page: and we want to check that the link is correct,
  # so we need to pass in the rec:
  def have_apply_btn(card, present = true)
    meth = present ? :have_link : :have_no_link
    send(meth, 'Find My Card', href: apply_card_recommendation_path(card))
  end

  def have_no_apply_btn(card)
    have_apply_btn card, false
  end

  def decline_reason_wrapper
    find('#card_decline_reason').find(:xpath, '..')
  end

  def set_approved_at_to(date)
    raise "error: approved at must be today or in the past" if date > Time.zone.today

    set_datepicker_field('#' << approved_at, to: date)
  end
end
