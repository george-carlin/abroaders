class CardAccount::InvalidStatusError < StandardError
end

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
      # previously applied, and are now hearing back from the bank (or they
      # nudged);
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
    when "redeny"
      account.redenied_at = Time.now
    else
      raise "unrecognized action '#{action}'"
    end

    # This could happen if e.g. the user has already made changes in a
    # different tab
    status = CardAccount::Status.new(account.attributes.slice(*CardAccount::Status::TIMESTAMPS))
    raise CardAccount::InvalidStatusError unless status.valid?

    account.save!
  end

end
