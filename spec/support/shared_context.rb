shared_context "logged in" do
  let(:user) { create(:user) } unless defined? user
  before { login_as user, scope: :user }
  after { Warden.test_reset! }
end

shared_context "logged in as admin" do
  let(:user) { create(:admin) } unless defined? user
  let(:admin) { user }
  before { login_as user, scope: :user }
  after { Warden.test_reset! }
end
