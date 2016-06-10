class PersonPresenter < ApplicationPresenter

  # The person signed up on the date their *account* was created, not on the
  # date which they added their passenger info in the survey. (In practice this
  # will usually be on the same date anyway, but bear it in mind.)
  def signed_up
    account.created_at.strftime("%D")
  end

  delegate :email, to: :account

  def readiness_given_on
    readiness_given_at.strftime("%D")
  end

  def link_to_new_card_recommendation
    h.link_to(
      "Recommend a card",
      h.new_admin_person_card_recommendation_path(self)
    )
  end


  def update_readiness_btn
    btn_classes = "btn btn-lg btn-primary"
    prefix = :update_readiness
    h.button_to(
        "I am now ready",
        h.person_readiness_status_path(self),
        class:  "#{h.dom_class(self, prefix)}_btn #{btn_classes} pull-right",
        id:     "#{h.dom_id(self, prefix)}_btn",
        method: :patch,
        data: { confirm: "Are you sure?" }
    )
  end

end
