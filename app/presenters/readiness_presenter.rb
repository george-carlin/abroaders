class ReadinessPresenter < ApplicationPresenter
  def unready_person
    if has_companion? && (owner.ready? || owner.ineligible?)
      return companion
    end
    owner
  end

  def both_can_update_ready?
    if has_companion?
      owner.unready? && companion.unready? && owner.eligible? && companion.eligible?
    else
      false
    end
  end
end
