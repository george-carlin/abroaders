# Note: This class was created before I invented the 'Form' abstraction. As
# such, it works very differently from the other '*Survey' classes in app/forms.
# I attempted to refactor it to make things more consistent, but decided it
# wasn't worth the trouble.
#
# I'm not even sure *how* to make this behave like a normal 'Form', because,
# unlike the other Forms, we won't know the exact list of fields until runtime
# (because it depends on what's in the Currencies table in the DB).
class BalancesSurvey

  attr_accessor :award_wallet_email
  attr_reader :balances, :errors

  def initialize(person)
    @person = person
    @balances = Currency.order("name ASC").map do |currency|
      @person.balances.build(currency: currency)
    end.to_a
  end

  def assign_attributes(params)
    # If the user has typed in values with commas, make sure that Ruby treats
    # this as the correct number:
    params.each { |balance| balance[:value].try :gsub!, /,/, '' }
    # if the value they submitted is '0', or if they left the text field empty,
    # then don't create a Balance object, but don't make the whole form
    # submission fail. If they submitted a value that's less than 0, then this
    # is a validation error, so don't create anything, and show the form again.
    params.reject! do |balance|
      balance[:value].blank? || balance[:value].to_i == 0
    end
    @balances = @person.balances.build(params).to_a
  end

  def save
    if valid?
      ApplicationRecord.transaction do
        @balances.each { |balance| balance.save!(validate: false) }
        @person.onboarded_balances = true
        if award_wallet_email.present?
          @person.award_wallet_email = award_wallet_email
        end
        @person.save(validate: false)

        if send_survey_complete_notification?
          AccountMailer.notify_admin_of_survey_completion(@person.account_id).deliver_later
        end

        IntercomJobs::TrackEvent.perform_later(
          email:      @person.account.email,
          event_name: "obs_balances_#{@person.type[0..2]}",
        )

        true
      end
    else
      @errors = @balances.flat_map do |balance|
        balance.errors.full_messages.map do |message|
          "#{balance.currency_name} #{message.downcase}"
        end
      end
      # Build balances for other currencies so they appear on the form:
      Currency.all.each do |currency|
        unless @balances.find { |b| b.currency_id == currency.id }
          @balances.push(@person.balances.build(currency: currency))
        end
      end
      @balances.sort_by! { |b| b.currency_name }
      false
    end
  end

  def valid?
    # Don't use 'all?' because we want to check *every* balance, so that every
    # invalid balance gets its error messages generated.
    result = true
    @balances.each { |b| result = false unless b.valid? }
    result
  end

  # ---------------- DUPE METHODS ----------------
  # If we ever make this into a proper subclass of `Form`, then the following
  # few methods are exact duplicates of code in that class, and can be removed
  # from this file:
  def self.transaction(&block)
    ActiveRecord::Base.transaction(&block)
  end

  def transaction(&block)
    self.class.transaction(&block)
  end

  def update_attributes(attributes)
    assign_attributes(attributes)
    save
  end
  # ---------------- /DUPE METHODS ---------------

  private

  def send_survey_complete_notification?
    !@person.eligible? && !(@person.main? && @person.account.has_companion?)
  end

end
