module ModalMacros

  def have_modal
    have_selector ".modal"
  end

  def have_no_modal
    have_no_selector ".modal"
  end

  def within_modal
    within ".modal" do
      yield
    end
  end

end
