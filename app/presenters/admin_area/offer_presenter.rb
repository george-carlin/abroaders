class AdminArea::OfferPresenter < OfferPresenter

  def link_to_edit
    h.link_to 'Edit', h.edit_admin_offer_path(self)
  end

  def link_to_show
    h.link_to 'Show', h.admin_offer_path(self)
  end

  def link_to_show_for_card
    h.link_to card_name, h.admin_card_offers_path(card)
  end

  def link_to_show_for_offer
    h.link_to 'Offer Link', link, :target => '_blank'
  end

  def kill_btn
    btn_classes = "btn btn-xs btn-primary"
    prefix = :kill
    h.button_to(
        "Kill",
        #h.admin_person_card_recommendations_path(person),
        h.kill_admin_offers_review_path(:id),
        class:  "#{h.dom_class(self, prefix)}_btn #{btn_classes} pull-right",
        id:     "#{h.dom_id(self, prefix)}_btn",
        params: { offer_id: id }
    )
  end
end
