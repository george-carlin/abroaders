class ReadinessPresenter < ApplicationPresenter
  def unready_person
    return companion if couples? && (owner.ready? || owner.ineligible?)
    owner
  end

  def both_can_update_ready?
    if couples?
      owner.unready? && companion.unready? && owner.eligible? && companion.eligible?
    else
      false
    end
  end
end
