class Recommendation::Cell::Admin::New < Trailblazer::Cell
  private

  def offer
    options.fetch(:offer)
  end

  def person
    options.fetch(:person)
  end

  BTN_CLASSES = 'btn btn-xs'.freeze

  def recommend_btn
    button_tag(
      'Recommend',
      class: "#{dom_class(offer, :recommend)}_btn #{BTN_CLASSES} btn-primary pull-right",
      id:    "#{dom_id(offer, :recommend)}_btn",
    )
  end

  def confirm_recommend_btn
    button_to(
      'Confirm',
      admin_person_recommendations_path(person),
      class:  "#{dom_class(offer, :confirm_recommend)}_btn #{BTN_CLASSES} btn-primary pull-right",
      id:     "#{dom_id(offer, :confirm_recommend)}_btn",
      remote: true,
      params: { recommendation: { offer_id: offer.id } },
    )
  end

  def cancel_recommend_btn
    prefix = :cancel_recommend
    button_tag(
      'Cancel',
      class: "#{dom_class(offer, prefix)}_btn #{BTN_CLASSES} btn-default pull-right",
      id:    "#{dom_id(offer, prefix)}_btn",
    )
  end
end
