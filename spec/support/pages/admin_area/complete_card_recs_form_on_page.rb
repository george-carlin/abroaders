module AdminArea
  class CompleteCardRecsFormOnPage < ObjectOnPage

    def dom_selector
      "#complete_card_recommendations"
    end

    def submit
      click_button "Done"
    end

    def add_recommendation_note(note)
      fill_in :recommendation_note, with: note
    end
    alias_method :add_rec_note, :add_recommendation_note

  end
end
