class CompanionsController < NonAdminController

  def new
    redirect_if_companion_present!
    @companion = NewCompanion.new(current_account)
  end

  def create
    redirect_if_companion_present!
    @companion = NewCompanion.new(current_account)
    if @companion.update_attributes(companion_params)
      redirect_to new_person_spending_info_path(@companion)
    else
      render "new"
    end
  end

  private

  def companion_params
    params.require(:companion).permit(:first_name)
  end

  def redirect_if_companion_present!
    if current_account.people.map(&:persisted?).count > 1
      redirect_to root_path
    end
  end

end
