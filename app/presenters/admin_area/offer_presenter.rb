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

end
