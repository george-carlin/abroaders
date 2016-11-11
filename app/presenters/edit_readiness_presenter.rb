class EditReadinessPresenter < ReadinessPresenter
  def submit_btn
    h.submit_tag(
      "Submit",
      class: "btn btn-primary update-readiness-btn",
    )
  end

  def readiness_who_hidden_field(person)
    h.hidden_field_tag(
      "readiness[who]",
      person.type,
    )
  end

  def submit_person_btn(person)
    h.submit_tag(
      "#{person.first_name} is now ready",
      class: "btn btn-primary update-readiness-btn",
    )
  end

  def cancel_btn
    h.link_to "Cancel", h.root_path, class: "btn btn-default update-readiness-btn"
  end

  def readiness_who_select
    h.select_tag(
      "readiness[who]",
      h.options_for_select([
                             ["Both of us are now ready", "both"],
                             ["#{owner.first_name} is now ready - #{companion.first_name} still needs more time", "owner"],
                             ["#{companion.first_name} is now ready - #{owner.first_name} still needs more time", "companion"],
                           ],),
    )
  end

  def person_reason(person)
    reason_title = couples? ? "#{person.first_name}'s reason:" : "Reason:"
    if person.unready? && person.unreadiness_reason.present?
      h.content_tag(:p) do
        "#{reason_title} #{h.content_tag(:i, person.unreadiness_reason)}".html_safe
      end
    end
  end
end
