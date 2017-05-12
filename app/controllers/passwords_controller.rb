class PasswordsController < Devise::PasswordsController
  layout 'basic'

  # GET /accounts/password/new
  def new
    self.resource = Account.new
    render cell(Password::Cell::New, resource)
  end

  # POST /accounts/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
    else
      render cell(Password::Cell::New, resource)
    end
  end

  # GET /accounts/password/edit?reset_password_token=abcdef
  def edit
    self.resource = resource_class.new
    set_minimum_password_length
    resource.reset_password_token = params[:reset_password_token]
    render cell(Password::Cell::Edit, resource)
  end

  # PUT /accounts/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      set_flash_message!(:notice, :updated)
      sign_in(resource_name, resource)
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      set_minimum_password_length
      render cell(Password::Cell::Edit, resource)
    end
  end
end
