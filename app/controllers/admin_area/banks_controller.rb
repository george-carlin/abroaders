module AdminArea
  class BanksController < AdminController
    def index
      @banks = Bank
                 .order(name: :asc)
                 .paginate(page: params[:page], per_page: 50)
    end

    def new
      @bank = NewBankForm.new
    end

    def create
      @bank = NewBankForm.new(bank_params)
      if @bank.save
        redirect_to admin_banks_path, notice: "Bank '#{@bank.name}' was successfully created."
      else
        render :new
      end
    end

    def edit
      @bank = EditBankForm.find(params[:id])
    end

    def update
      @bank = EditBankForm.find(params[:id])
      if @bank.update(bank_params)
        redirect_to admin_banks_path, notice: "Bank '#{@bank.name}' was successfully updated."
      else
        render :edit
      end
    end

    def destroy
      bank = Bank.find(params[:id])
      bank.destroy!
      redirect_to admin_banks_path, notice: "Bank '#{bank.name}' was deleted."
    end

    private

    def bank_params
      params.require(:bank).permit(:name, :business_phone, :personal_phone)
    end
  end
end
