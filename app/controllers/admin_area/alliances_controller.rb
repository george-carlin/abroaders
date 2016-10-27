module AdminArea
  class AlliancesController < AdminController
    def index
      @alliances = Alliance
                   .order(name: :asc)
                   .paginate(page: params[:page], per_page: 50)
    end

    def new
      @alliance = NewAllianceForm.new
    end

    def create
      @alliance = NewAllianceForm.new(alliance_params)
      if @alliance.save
        redirect_to admin_alliances_path, notice: "Alliance '#{@alliance.name}' was successfully created."
      else
        render :new
      end
    end

    def edit
      @alliance = EditAllianceForm.find(params[:id])
    end

    def update
      @alliance = EditAllianceForm.find(params[:id])
      if @alliance.update(alliance_params)
        redirect_to admin_alliances_path, notice: "Alliance '#{@alliance.name}' was successfully updated."
      else
        render :edit
      end
    end

    def destroy
      alliance = Alliance.find(params[:id])
      alliance.destroy!
      redirect_to admin_alliances_path, notice: "Alliance '#{alliance.name}' was deleted."
    end

    private

    def alliance_params
      params.require(:alliance).permit(:name)
    end
  end
end
