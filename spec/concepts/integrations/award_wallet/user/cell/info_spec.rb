require 'cells_helper'

require 'integrations/award_wallet/user/cell/info'

RSpec.describe Integrations::AwardWallet::User::Cell::Info do
  example '' do
    user = AwardWalletUser.new(
      id: 1,
      full_name: 'Fred Bloggs',
      user_name: 'freddieb',
      email: 'fred.bloggs@example.com',
    )
    rendered = cell(user).()
    expect(rendered).to have_content 'Fred Bloggs'
    expect(rendered).to have_content 'freddieb'
    expect(rendered).to have_content 'fred.bloggs@example.com'
  end

  example 'XSS protection' do
    user = AwardWalletUser.new(
      id: 1,
      account_id: 1,
      full_name: '<fullname>',
      user_name: '<username>',
      email: '<email>',
    )
    rendered = raw_cell(user).to_s
    expect(rendered).to include '&lt;fullname&gt;'
    expect(rendered).to include '&lt;username&gt;'
    expect(rendered).to include '&lt;email&gt;'
  end
end
