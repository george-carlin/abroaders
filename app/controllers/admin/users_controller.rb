module Admin
  class UsersController < ApplicationController

    # GET /admin_panel/users
    def index
      @users = User.non_admin
    end

    # GET /admin_panel/users/1
    def show
      @user = get_user
    end

    # GET /admin_panel/users/new
    def new
      @user = User.new
    end

    # GET /admin_panel/users/1/edit
    def edit
      @user = get_user
    end

    # POST /admin_panel/users
    def create
      @user = User.new(user_params)

      if @user.save
        redirect_to @user, notice: 'User was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /admin_panel/users/1
    def update
      @user = get_user
      if @user.update(user_params)
          redirect_to @user, notice: 'User was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /admin_panel/users/1
    def destroy
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
