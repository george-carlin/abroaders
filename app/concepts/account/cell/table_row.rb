class Account::Cell < Trailblazer::Cell
  class TableRow < Trailblazer::Cell
    include ActionView::Helpers::RecordTagHelper

    property :companion
    property :couples?
    property :created_at
    property :email
    property :onboarded?
    property :owner
    property :people

    private

    def onboarded_icon
      onboarded? ? raw('<i class="fa fa-check"> </i>') : ''
    end

    def tr(&block)
      content_tag_for(
        :tr,
        model,
        {
          'data-companion-name': companion&.first_name,
          'data-email':          email,
          'data-onboarded':      onboarded?,
          'data-owner-name':     owner.first_name,
        },
        &block
      )
    end

    def link_to_owner
      link_to_person(owner)
    end

    def link_to_companion
      couples? ? link_to_person(companion) : '-'
    end

    def created_at
      super.strftime('%D')
    end

    def last_recommendations_at
      timestamps = people.map(&:last_recommendations_at).compact
      timestamps.any? ? timestamps.max.strftime('%D') : '-'
    end

    def person_readiness_icon(person)
      ::Person::Cell::ReadinessIcon.(person).()
    end

    def link_to_person(person)
      text = "#{person.first_name} #{person_readiness_icon(person)}"
      link_to text, admin_person_path(person)
    end
  end
end
