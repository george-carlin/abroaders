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

  private

  def link_to_person(person)
    text = [person.first_name]
    if person.ready_to_apply?
      text << "(R)"
    elsif person.eligible?
      text << "(E)"
    end
    h.link_to text.join(" "), h.admin_person_path(person)
  end

end
