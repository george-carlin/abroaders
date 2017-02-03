class AdminArea::OfferPresenter < ::OfferPresenter
  def initialize(*)
    warn "#{self.class} is deprecated"
    line = caller.select { |l| l.include?(Rails.root.to_s) }[1].split(':')[0..1].join(':')
    warn "Called from #{line}"
    super
  end

  def product_bp
    product.bp.to_s[0].upcase
  end

  def product_identifier
    AdminArea::CardProduct::Cell::Identifier.(product).()
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
    warn "#{self.class}#spend is deprecated. Use AdminArea::Offer::Cell::LastReviewedAt instead."
    line = caller.select { |l| l.include?(Rails.root.to_s) }[1].split(':')[0..1].join(':')
    warn "Called from #{line}"

    AdminArea::Offer::Cell::LastReviewedAt.(model).()
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
