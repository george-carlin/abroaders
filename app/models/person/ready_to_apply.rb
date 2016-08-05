module Person::ReadyToApply
  extend ActiveSupport::Concern

  def readiness_given?
    !ready.nil?
  end


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