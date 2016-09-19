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

  def name
    if has_companion?
      if owner.unready? && companion.unready?
        "#{owner.first_name} and #{companion.first_name}"
      elsif owner.unready?
        owner.first_name
      elsif companion.unready?
        companion.first_name
      end
    else
      "you"
    end
  end

  def both_unready?
    if has_companion?
      owner.unready? && companion.unready?
    else
      true
    end
  end

  def update_both_readiness_btn
    update_readiness_btn("both", "Both are ready")
  end

  def update_owner_readiness_btn(prefix: nil)
    update_readiness_btn("owner", "#{prefix} #{owner.first_name} is ready")
  end

  def update_companion_readiness_btn(prefix: nil)
    update_readiness_btn("companion", "#{prefix} #{companion.first_name} is ready")
  end

  def update_self_readiness_btn
    update_readiness_btn("owner", "I am now ready")
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

  def update_readiness_btn(data, text)
    btn_classes = "btn btn-md btn-primary readiness-btn"
    prefix = "update_#{data}_readiness".to_sym
    button = h.button_to(
                  text,
                  h.send("update_#{data}_readiness_path"),
                  class:  "#{h.dom_class(self, prefix)}_btn #{btn_classes}",
                  id:     "#{h.dom_id(self, prefix)}_btn",
                  method: :patch,
                  data: { confirm: "Are you sure?" }
    )
    h.content_tag(:div, button, class: "col-md-6 col-lg-3")
  end

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
