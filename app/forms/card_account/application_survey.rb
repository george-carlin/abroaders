class CardAccount::ApplicationSurvey < ApplicationForm
  include Virtus.model

  attribute :account,   CardAccount
  attribute :action,    String
  attribute :opened_at, Date

  # TODO once the 'refactor-forms' branch is merged, delete this method:
  def save
    super do
      persist!
    end
  end

  validate :action_is_possible

  def persist!
    case action
    when "apply"
      account.applied_at = Time.now
    when "call"
      account.called_at = Time.now
    when "call_and_open"
      account.called_at = account.opened_at = Time.now
    when "call_and_deny"
      account.called_at = account.redenied_at = Time.now
    when "deny"
      account.denied_at  = Time.now
      # Don't update applied_at if it's already present: they may have
      # previously applied, and are only now hearing back from the bank:
      account.applied_at ||= Time.now
    when "open"
      if opened_at.present?
        account.opened_at = opened_at
      else
        account.opened_at = Time.now
      end
      # Don't update applied_at if it's already present: they may have
      # previously applied, and are only now hearing back from the bank:
      account.applied_at ||= account.opened_at
    when "nudge"
      account.nudged_at = Time.now
    when "nudge_and_open"
      account.nudged_at = account.opened_at = Time.now
    when "nudge_and_deny"
      account.nudged_at = account.denied_at = Time.now
    when "reconsider_and_open"
      account.opened_at = Time.now
    when "reconsider_and_deny"
      account.redenied_at = Time.now
    else
      raise "unrecognized action '#{action}'"
    end
    account.save!
  end

  private

  def action_is_possible
    status = CardAccount::Status.new(account.attributes.slice(*CardAccount::Status::TIMESTAMPS))

    # Urgh..... very repetitive. FIXME
    case action
    when "apply"
      status.applied_at = Time.now
    when "call"
      status.called_at = Time.now
    when "call_and_open"
      status.called_at = status.opened_at = Time.now
    when "call_and_deny"
      status.called_at = status.redenied_at = Time.now
    when "deny"
      status.denied_at  = Time.now
      # Don't update applied_at if it's already present: they may have
      # previously applied, and are only now hearing back from the bank:
      status.applied_at ||= Time.now
    when "open"
      if opened_at.present?
        status.opened_at = opened_at
      else
        status.opened_at = Time.now
      end
      # Don't update applied_at if it's already present: they may have
      # previously applied, and are only now hearing back from the bank:
      status.applied_at ||= status.opened_at
    when "nudge"
      status.nudged_at = Time.now
    when "nudge_and_open"
      status.nudged_at = status.opened_at = Time.now
    when "nudge_and_deny"
      status.nudged_at = status.denied_at = Time.now
    when "reconsider_and_open"
      status.opened_at = Time.now
    when "reconsider_and_deny"
      status.redenied_at = Time.now
    end

    if !status.valid?
      errors.add(:action, "not possible for this card account")
    end
  end
end
