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

  def dashboard_options
    if ready?
      partial_name = "accounts/dashboard/ready"
      title = t("dashboard.account.ready.title")
    elsif eligible?
      partial_name = "accounts/dashboard/eligible"
      title = t("dashboard.account.eligible.title")
    else
      partial_name = "accounts/dashboard/ineligible"
      title = t("dashboard.account.ineligible.title")
    end

    { title: title, partial_name: partial_name }
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
