class AdminArea::OfferPresenter < ::OfferPresenter
  def product_bp
    product.bp.to_s[0].upcase
  end

  def cancel_recommend_btn
    btn_classes = "btn btn-xs btn-default"
    prefix = :cancel_recommend
    h.button_tag(
      "Cancel",
      class: "#{h.dom_class(self, prefix)}_btn #{btn_classes} pull-right",
      id:    "#{h.dom_id(self, prefix)}_btn",
    )
  end

  def confirm_recommend_btn(person)
    btn_classes = "btn btn-xs btn-primary"
    prefix = :confirm_recommend
    h.button_to(
      "Confirm",
      h.admin_person_recommendations_path(person),
      class:  "#{h.dom_class(self, prefix)}_btn #{btn_classes} pull-right",
      id:     "#{h.dom_id(self, prefix)}_btn",
      params: { offer_id: id },
    )
  end

  def confirm_recommend_form(person)
    h.form_for(
      [:admin, person, AdminArea::Recommendation.new(offer_id: id)],
      data: { remote: true },
      html: { style: "display:none" },
    ) do |f|
      yield(f)
    end
  end

  def kill_btn
    btn_classes = "btn btn-xs"
    prefix = :kill
    # link_to used to allow btn-group functionality
    h.link_to(
      "Kill",
      h.kill_admin_offer_path(id),
      class:  "#{h.dom_class(self, prefix)}_btn #{btn_classes} btn-danger",
      id:     "#{h.dom_id(self, prefix)}_btn",
      params: { offer_id: id },
      method: :patch,
      remote: true,
      data: { confirm: "Are you sure?" },
    )
  end

  def link_to_edit
    h.link_to 'Edit', h.edit_admin_offer_path(self)
  end

  def link_to_show
    h.link_to 'Show', h.admin_offer_path(self)
  end

  def link_to_show_for_card
    h.link_to product_name, h.admin_card_product_offers_path(product)
  end

  def link_to_show_for_offer
    h.link_to 'Link', link, target: '_blank'
  end

  def last_reviewed_at
    super().nil? ? "never" : super().strftime("%m/%d/%Y")
  end

  def recommend_btn
    btn_classes = "btn btn-xs btn-primary"
    prefix = :recommend
    h.button_tag(
      "Recommend",
      class: "#{h.dom_class(self, prefix)}_btn #{btn_classes} pull-right",
      id:    "#{h.dom_id(self, prefix)}_btn",
    )
  end

  def verify_btn
    btn_classes = "btn btn-xs btn-primary"
    prefix = :verify
    # link_to used to allow btn-group functionality
    h.link_to(
      "Verify",
      h.verify_admin_offer_path(id),
      class:  "#{h.dom_class(self, prefix)}_btn #{btn_classes} ",
      id:     "#{h.dom_id(self, prefix)}_btn",
      params: { offer_id: id },
      method: :patch,
      remote: true,
    )
  end
end
