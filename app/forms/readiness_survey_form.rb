class ReadinessSurveyForm < ReadinessForm
  attribute :owner_unreadiness_reason,     String
  attribute :companion_unreadiness_reason, String

  def self.name
    "ReadinessSurvey"
  end

  private

  def owner
    @owner ||= account.owner
  end

  def companion
    @companion ||= account.companion
  end

  def persist!
    super

    if owner.unready && owner_unreadiness_reason
      owner.update!(unreadiness_reason: owner_unreadiness_reason)
    end

    if companion && companion.unready && companion_unreadiness_reason
      companion.update!(unreadiness_reason: companion_unreadiness_reason)
    end

    account.update!(onboarded_readiness: true)
  end

  def update_person!(person, send_email: false)
    person.update!(ready: true)
  end
end
