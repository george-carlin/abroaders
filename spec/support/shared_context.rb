shared_context "logged in as new user" do
  let(:account) { create(:account) } unless defined? account
  before { login_as account, scope: :account }
end

shared_context "logged in" do
  let(:account) { create(:account, :onboarded) } unless defined? account
  before { login_as account, scope: :account }
end

shared_context "logged in as admin" do
  let(:admin) { create(:admin) }
  before { login_as admin, scope: :admin }
end
