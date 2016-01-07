class SpendingInfosController < ApplicationController

  # GET /spending_infos/1
  # GET /spending_infos/1.json
  def show
  end

  # GET /spending_infos/new
  def new
    @spending_info = current_user.build_spending_info
  end

  # GET /spending_infos/1/edit
  def edit
  end

  # POST /spending_infos
  # POST /spending_infos.json
  def create
    @spending_info = current_user.build_spending_info(spending_info_params)

    if @spending_info.save
      # TODO handle this better
      redirect_to root_path
    else
      render :new
    end
  end

  # PATCH/PUT /spending_infos/1
  # PATCH/PUT /spending_infos/1.json
  def update
    respond_to do |format|
      if @spending_info.update(spending_info_params)
        format.html { redirect_to @spending_info, notice: 'Spending info was successfully updated.' }
        format.json { render :show, status: :ok, location: @spending_info }
      else
        format.html { render :edit }
        format.json { render json: @spending_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /spending_infos/1
  # DELETE /spending_infos/1.json
  def destroy
    @spending_info.destroy
    respond_to do |format|
      format.html { redirect_to spending_infos_url, notice: 'Spending info was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_spending_info
    @spending_info = SpendingInfo.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def spending_info_params
    params.require(:spending_info).permit(
      :user_id, :citizenship, :credit_score, :will_apply_for_loan,
      :spending_per_month_dollars, :has_business
    )
  end
end
