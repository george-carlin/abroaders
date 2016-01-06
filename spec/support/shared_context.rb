shared_context "logged in" do
  let(:user) { create(:user) } unless defined? user
  before { login_as user, scope: :user }
  after { Warden.test_reset! }
end
