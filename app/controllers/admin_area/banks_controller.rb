module AdminArea
  class BanksController < AdminController
    def index
      @banks = Bank.all.order(personal_code: :asc)
    end

    def edit
      @bank = Bank::Form.new(load_bank)
    end

    def update
      @bank = Bank::Form.new(load_bank)
      if @bank.validate(params[:bank])
        @bank.save
        flash[:success] = "Updated bank '#{@bank.model.name}!'"
        redirect_to admin_banks_path
      else
        render 'edit'
      end
    end

    private

    def load_bank
      Bank.find(params[:id])
    end
  end
end
