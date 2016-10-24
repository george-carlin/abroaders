module AdminArea
  class EditTravelPlanForm < ::EditTravelPlanForm
    def form_object
      [:admin, self]
    end

    def owner
      travel_plan.account.owner
    end

    def owner_name(suffix = false)
      suffix = suffix ? "'s" : ""
      "#{owner.first_name}#{suffix}"
    end
  end
end
