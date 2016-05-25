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
    when "open"
      if opened_at.present?
        account.applied_at = account.opened_at = Date.strptime(opened_at, "%m/%d/%Y")
      else
        account.applied_at = account.opened_at = Time.now
      end
    when "deny"
      account.applied_at = Time.now
      account.denied_at  = Time.now
    when "apply"
      account.applied_at = Time.now
    when "open_after_call"
      account.called_at = Time.now
      account.opened_at = Time.now
    when "redeny"
      account.called_at = Time.now
      account.redenied_at = Time.now
    when "call"
      account.called_at = Time.now
    else
      raise "unrecognized action '#{action}'"
    end
    account.save!
  end

  private

  def action_is_possible
    status = CardAccount::Status.new(account.attributes.slice(*CardAccount::Status::TIMESTAMPS))

    case action
    when "open"
      status.opened_at = status.applied_at = Time.now
    when "deny"
      status.denied_at = status.applied_at = Time.now
    when "apply"
      status.applied_at = Time.now
    end

    if !status.valid?
      errors.add(:action, "not possible for this card account")
    end
  end
end
