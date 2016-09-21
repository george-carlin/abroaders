class AccountPresenter < ApplicationPresenter
  def tr(&block)
    h.content_tag_for(
      :tr,
      self,
      {
        "data-companion-name": companion&.first_name,
        "data-email":          email,
        "data-onboarded":      onboarded?,
        "data-owner-name":     owner.first_name,
      },
      &block
    )
  end

  def link_to_owner
    link_to_person(owner)
  end

  def link_to_companion
    has_companion? ? link_to_person(companion) : "-"
  end

  def created_at
    super.strftime("%D")
  end

  def last_recommendations_at
    timestamps = people.map(&:last_recommendations_at).compact
    timestamps.any? ? timestamps.max.strftime("%D") : "-"
  end

  def both_can_update_ready?
    if has_companion?
      owner.unready? && companion.unready? && owner.eligible? && companion.eligible?
    else
      false
    end
  end

  def unready_person
    if has_companion? && (owner.ready? || owner.ineligible?)
      return companion
    end
    owner
  end

  def submit_btn
    button = h.submit_tag(
        "Submit",
        class: "btn btn-primary readiness-btn",
    )
    h.content_tag(:div, button, class: "col-md-6 col-lg-3")
  end

  def submit_person_btn(person)
    hidden = h.text_field_tag(
        "readiness[who]",
        person == owner ? "owner" : "companion",
        type: "hidden"
    )
    button = h.submit_tag(
        "#{person.first_name} is now ready",
        class: "btn btn-primary readiness-btn",
    )
    h.content_tag(:div, hidden + button, class: "col-md-6 col-lg-6")
  end

  def cancel_btn
    button = h.link_to(
        "Cancel",
        h.root_path,
        class: "btn btn-default readiness-btn",
    )
    h.content_tag(:div, button, class: "col-md-6 col-lg-3")
  end

  def select_options
    [
      ["Both of us are now ready", "both"],
      ["#{owner.first_name} is now ready - #{companion.first_name} steel needs more time", "owner"],
      ["#{companion.first_name} is now ready - #{owner.first_name} steel needs more time", "companion"],
    ]
  end

  def person_reason(person)
    reason_title = has_companion? ? "#{person.first_name}'s reason:" : "Reason:"
    if person.unready? && person.unreadiness_reason.present?
      h.content_tag(:p) do
        "#{reason_title} #{h.content_tag(:i, person.unreadiness_reason)}".html_safe
      end
    end
  end

  private

  def link_to_person(person)
    text = [person.first_name]
    if person.ready?
      text << "(R)"
    elsif person.eligible?
      text << "(E)"
    end
    h.link_to text.join(" "), h.admin_person_path(person)
  end
end
