module ApplicationSurveyMacros
  # The apply 'button' is actually a link styled like a button

  def self.included(base)
    base.include DatepickerMacros
    base.extend ClassMethods
    base.instance_eval do
      # some of these buttons have different text for different survey stages,
      # so you'll have to override these let variables where appropriate:
      let(:approved_at)      { 'card_opened_on' }
      let(:decline_btn)      { 'No Thanks' }
      let(:i_applied_btn)    { 'I applied' }
      let(:pending_btn)      { "I'm waiting to hear back" }
      let(:approved_btn) { 'I was approved' }
      let(:denied_btn)   { 'My application was denied' }
    end
  end

  def i_called_btn(rec)
    "I called #{rec.card_product.bank.name}"
  end

  def i_heard_back_btn(rec = nil)
    if rec
      "I heard back from #{rec.bank_name} by mail or email"
    else
      'I heard back from the bank'
    end
  end

  # apply btn is different from the others because it's actually a link
  # to another page (styled like a button) rather than a button that changes
  # something on the current page: and we want to check that the link is correct,
  # so we need to pass in the rec:
  def have_find_card_btn(card, present = true)
    meth = present ? :have_link : :have_no_link
    send(meth, 'Find My Card', href: click_card_recommendation_path(card))
  end

  def have_no_find_card_btn(card)
    have_find_card_btn card, false
  end

  def decline_reason_wrapper
    find('#card_decline_reason').find(:xpath, '..')
  end

  def set_approved_at_to(date)
    raise "error: approved at must be today or in the past" if date > Time.zone.today

    set_datepicker_field('#' << approved_at, to: date)
  end

  module ClassMethods
    def it_asks_to_confirm(has_pending_btn:)
      example 'it can be confirmed/canceled' do
        expect(page).to have_no_button approved_btn
        expect(page).to have_no_button denied_btn
        expect(page).to have_no_button pending_btn
        expect(page).to have_button 'Cancel'
        expect(page).to have_button 'Confirm'
        # going back
        click_button 'Cancel'
        expect(page).to have_button approved_btn
        expect(page).to have_button denied_btn
        expect(page).to has_pending_btn ? have_button(pending_btn) : have_no_button(pending_btn)
        expect(page).to have_no_button 'Confirm'
      end
    end
  end
end
