module AdminArea
  module CardRecommendations
    class Update < Card::Update
      self['edit_op'] = AdminArea::CardRecommendations::Edit
    end
  end
end
