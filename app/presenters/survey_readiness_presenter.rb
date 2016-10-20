class SurveyReadinessPresenter < ReadinessPresenter
  def radio_as_button(text, value, options = {})
    options = { selected: false, icon: "check" }.merge(options)
    active_class = options[:selected] ? "active" : ""
    h.content_tag(:label, "readiness_survey[who]", class: "readiness-radio btn btn-default #{active_class}") do
      h.content_tag(:span, nil, class: "fa fa-#{options[:icon]}") +
        h.radio_button_tag("readiness_survey[who]", value, options[:selected]) +
        text
    end
  end

  def unreadiness_reason(person)
    name = has_companion? ? "#{person.first_name} isn't" : "you aren't"
    h.content_tag(:div, "", class: "form-group unreadiness_reason_form_group #{person.type}") do
      h.text_field("readiness_survey", "#{person.type}_unreadiness_reason", placeholder: "Optional: tell us why #{name} ready to apply just yet")
    end
  end
end
