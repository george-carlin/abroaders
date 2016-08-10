module Person::ReadyToApply
  extend ActiveSupport::Concern

  included do
    has_one :readiness_status
    delegate :unreadiness_reason, to: :readiness_status, allow_nil: true
  end

  # TODO we're getting rid of the ReadinessStatus model soon (it's
  # been done in a PR that's still unmerged.) Once that's done,
  # remove all references to 'readiness_given' and use only
  # 'onboarded_readiness?', to keep things consistent with the other
  # methods that have names like 'onboarded_x?'
  def readiness_given?
    !!readiness_status&.persisted?
  end
  alias_method :onboarded_readiness?, :readiness_given?

  def ready_to_apply?
    !!readiness_status&.ready?
  end

  def unready_to_apply?
    !ready_to_apply?
  end

  def readiness_given_at
    readiness_status&.updated_at
  end

  def ready_to_apply!
    build_readiness_status(ready: true)
    readiness_status.save! if persisted?
  end

  def unready_to_apply!(reason: nil)
    build_readiness_status(ready: false, unreadiness_reason: reason)
    readiness_status.save! if persisted?
  end
end
