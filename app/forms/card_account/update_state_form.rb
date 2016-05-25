class CardAccount::UpdateStateForm < ApplicationForm
  include Virtus.model

  attribute :account,        CardAccount
  attribute :decline_reason, String

  attribute :applied_at,  Date
  attribute :declined_at, Date
  attribute :denied_at,   Date
  attribute :opened_at,   Date

  validates :decline_reason, presence: { if: "declined_at.present?" }

  # TODO once the 'refactor-forms' branch is merged, delete this method:
  def save
    super do
      persist!
    end
  end

  def persist!
    # Make sure we don't nullify any existing values:
    account.applied_at     = applied_at     if applied_at.present?
    account.decline_reason = decline_reason if decline_reason.present?
    account.declined_at    = declined_at    if declined_at.present?
    account.denied_at      = denied_at      if denied_at.present?
    account.opened_at      = opened_at      if opened_at.present?
    account.save!
  end

end
