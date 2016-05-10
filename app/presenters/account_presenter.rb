class AccountPresenter < ApplicationPresenter

  def tr(&block)
    h.content_tag_for(
      :tr,
      self,
      {
        "data-companion-name":      companion&.first_name,
        "data-email":               email,
        "data-main-passenger-name": main_passenger.first_name,
        "data-onboarded":           onboarded?,
      },
      &block
    )
  end

  def render_main_passenger
    h.render "admin_area/people/table_cell", person: main_passenger
  end

  def render_companion
    if has_companion?
      h.render "admin_area/people/table_cell", person: companion
    else
      "-"
    end
  end

  def created_at
    super.strftime("%D")
  end

  def last_recommendations_at
    timestamps = people.map(&:last_recommendations_at).compact
    timestamps.any? ? timestamps.max.strftime("%D") : "-"
  end
end
