module AdminArea
  class BanksController < AdminController
    def index
      @banks = Bank.all.order(name: :asc)
    end

    def edit
      @bank = Bank::Form.new(Bank.find(params[:id]))
    end

    def update
      @bank = Bank::Form.new(Bank.find(params[:id]))
      if @bank.validate(params[:bank])
        @bank.save
        flash[:success] = "Updated bank '#{@bank.model.name}!'"
        redirect_to admin_banks_path
      else
        render 'edit'
      end
    end
  end
end
