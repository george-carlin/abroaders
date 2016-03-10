shared_context "logged in as new user" do
  let(:account) { create(:account) } unless defined? account
  before { login_as account, scope: :account }
  after { Warden.test_reset! }
end

shared_context "logged in" do
  let(:account) { create(:account, :survey_complete) } unless defined? account
  before { login_as account, scope: :account }
  after { Warden.test_reset! }
end

shared_context "logged in as admin" do
  let(:account) { create(:admin) } unless defined? account
  let(:admin) { account }
  before { login_as account, scope: :account }
  after { Warden.test_reset! }
end
