module Admin
  class UsersController < AdminController

    # GET /admin/users
    def index
      @users = User.includes(:survey).non_admin
    end

    # GET /admin/users/1
    def show
      @user = get_user
      @card_accounts = @user.card_accounts.select(&:persisted?)
      @card_recommendation = @user.card_accounts.new
      # Use @user.card_accounts here instead of @card_accounts because
      # the latter is an Array, not a Relation (because of
      # `.select(&:persisted?)`)
      @cards = Card.where.not(id: @user.card_accounts.select(:card_id))
    end

    # GET /admin/users/new
    def new
      raise "not yet implemented"
      @user = User.new
    end

    # GET /admin/users/1/edit
    def edit
      raise "not yet implemented"
      @user = get_user
    end

    # POST /admin/users
    def create
      raise "not yet implemented"
      @user = User.new(user_params)

      if @user.save
        redirect_to @user, notice: 'User was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /admin/users/1
    def update
      raise "not yet implemented"
      @user = get_user
      if @user.update(user_params)
          redirect_to @user, notice: 'User was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /admin/users/1
    def destroy
      raise "not yet implemented"
      @user = get_user
      @user.destroy
      redirect_to users_url, notice: 'User was successfully destroyed.'
    end

    private

    def get_user
      User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params[:user]
    end
  end
end
