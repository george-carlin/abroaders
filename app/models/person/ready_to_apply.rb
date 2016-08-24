module Person::ReadyToApply
  extend ActiveSupport::Concern

  # Now that we've got rid of the ReadinessStatus model, remove remove all
  # references to 'readiness_given' and use only 'onboarded_readiness?', to
  # keep things consistent with the other methods that have names like
  # 'onboarded_x?'
  def readiness_given?
    !ready.nil?
  end
  alias_method :onboarded_readiness?, :readiness_given?


  def unready_to_apply?
    !ready_to_apply?
  end

  def ready_to_apply!
    if eligible
      self.ready = true
      self.save! if persisted?
    else
      raise "Can't set ready for ineligible person"
    end
  end

  def unready_to_apply!(reason: nil)
    if eligible
      self.ready = false
      self.unreadiness_reason = reason
      self.save! if persisted?
    else
    raise "Can't set ready for ineligible person"
    end
  end
end
