# I've removed all presenters except this one. This one needs to go too, but
# it's not worth the effort of converting readiness/edit (the only page that
# uses this presenter) into a cell because we're going to make big changes to
# the readiness system in the near future and that page is likely to be
# completely overhauled (or removed) anyway
class EditReadinessPresenter < SimpleDelegator
  include I18nWithErrorRaising

  def initialize(model, view)
    @model = model
    @view  = view
    super(@model)
  end

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

  def person_reason(_person)
    'TODO remove #person_reason'
  end

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

  private

  def h
    view
  end

  def raw(*args)
    h.raw(*args)
  end

  attr_reader :view
end
