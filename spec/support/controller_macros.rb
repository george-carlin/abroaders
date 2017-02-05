RSpec.shared_context "account devise mapping" do
  before { @request.env["devise.mapping"] = Devise.mappings[:account] }
end

RSpec.shared_context "admin devise mapping" do
  before { @request.env["devise.mapping"] = Devise.mappings[:admin] }
end

module ControllerMacros
  def login_as_account(account)
    include_context "account devise mapping"
    before { sign_in account }
  end

  def login_as_admin(admin)
    include_context "admin devise mapping"
    before { sign_in admin }
  end
end
