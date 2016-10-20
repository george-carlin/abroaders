class ReadinessPresenter < ApplicationPresenter
  def unready_person
    return companion if has_companion? && (owner.ready? || owner.ineligible?)
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
