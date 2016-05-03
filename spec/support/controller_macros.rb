module ControllerMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in create(:admin)
    end
  end

  def login_account
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:account]
      sign_in create(:account)
    end
  end
end
