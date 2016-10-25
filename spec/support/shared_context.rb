shared_context "logged in" do
  let(:account) { create(:account, :onboarded) }
  before { login_as(account) }
end

shared_context "logged in as admin" do
  let(:admin) { create(:admin) }
  before { login_as_admin(admin) }
end
