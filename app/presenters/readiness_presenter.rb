class ReadinessPresenter < ApplicationPresenter
  def both_can_update_ready?
    if has_companion?
      owner.unready? && companion.unready? && owner.eligible? && companion.eligible?
    else
      false
    end
  end
end
