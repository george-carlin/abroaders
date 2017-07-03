class Card::InvalidStatusError < StandardError
end

class Card::ApplicationSurvey < ApplicationForm
  attribute :card,      Card
  attribute :action,    String
  attribute :opened_on, Date

  def persist!
    case action
    when "apply"
      card.applied_on = Time.now
    when "call"
      card.called_at = Time.now
    when "call_and_open"
      card.called_at = card.opened_on = Time.now
    when "call_and_deny"
      card.called_at = card.redenied_at = Time.now
    when "deny"
      card.denied_at = Time.now
      # Don't update applied_on if it's already present: they may have
      # previously applied, and are now hearing back from the bank (or they
      # nudged);
      card.applied_on ||= Time.now
    when "open"
      card.opened_on = opened_on || Time.now
      # Don't update applied_on if it's already present: they may have
      # previously applied, and are only now hearing back from the bank:
      card.applied_on ||= card.opened_on
    when "nudge"
      card.nudged_at = Time.now
    when "nudge_and_open"
      card.nudged_at = card.opened_on = Time.now
    when "nudge_and_deny"
      card.nudged_at = card.denied_at = Time.now
    when "redeny"
      card.redenied_at = Time.now
    else
      raise "unrecognized action '#{action}'"
    end

    # Catch inconsistencies that may occur if e.g. the user has two tabs open
    # and takes different actions in each one. This error will be caught by the
    # controller, and a generic 'could not update' message will be shown to the
    # user
    raise Card::InvalidStatusError unless CardRecommendation::Validate.(card)

    card.save!
  end
end
