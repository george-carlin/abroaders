class ReadinessSurvey < ReadinessForm
  attribute :owner_unreadiness_reason,     String
  attribute :companion_unreadiness_reason, String

  private

  def persist!
    super

    if owner.unready && owner_unreadiness_reason.present?
      owner.update!(unreadiness_reason: owner_unreadiness_reason.strip)
    end

    if companion.present? && companion.unready && companion_unreadiness_reason.present?
      companion.update!(unreadiness_reason: companion_unreadiness_reason.strip)
    end

    AccountOnboarder.new(account).add_readiness!
  end
end
