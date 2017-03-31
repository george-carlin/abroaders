require 'rails_helper'

RSpec.describe Integrations::AwardWallet::Owner::Operation::UpdatePerson do
  include AwardWalletMacros

  let(:op) { described_class }

  let(:account)   { create(:account, :couples, :onboarded) }
  let(:owner)     { account.owner }
  let(:companion) { account.companion }

  let(:aw_user) { setup_award_wallet_user_from_sample_data(account) }
  let(:aw_owner) { aw_user.award_wallet_owners.first }

  example 'account not connected to award wallet' do
    raise unless account.award_wallet_user.nil? # sanity check
    expect do
      op.({ id: 1, person_id: owner.id }, 'account' => account)
    end.to raise_error ActiveRecord::RecordNotFound
  end

  example 'updating from one person to another person' do
    result = op.({ id: aw_owner.id, person_id: companion.id }, 'account' => account)
    expect(result.success?).to be true
    updated_owner = result['model']
    expect(updated_owner).to eq aw_owner
    expect(updated_owner.person).to eq companion
  end

  example 'updating from non-nil to nil' do
    raise unless aw_owner.person == owner # sanity check

    result = op.({ id: aw_owner.id, person_id: nil }, 'account' => account)
    expect(result.success?).to be true
    updated_owner = result['model']
    expect(updated_owner).to eq aw_owner
    expect(updated_owner.person).to be nil
  end

  example 'passing a blank string as the person ID' do
    # this is what the HTML form will do, so we must be able to handle it
    raise unless aw_owner.person == owner # sanity check

    result = op.({ id: aw_owner.id, person_id: '' }, 'account' => account)
    expect(result.success?).to be true
    expect(result['model'].person).to be nil
  end

  example 'updating from nil to non-nil' do
    # setup to nil:
    op.({ id: aw_owner.id, person_id: nil }, 'account' => account)
    # and back to non-nil
    result = op.({ id: aw_owner.id, person_id: owner.id }, 'account' => account)
    expect(result.success?).to be true
    updated_owner = result['model']
    expect(updated_owner).to eq aw_owner
    expect(updated_owner.person).to eq owner
  end

  example "error - updating someone else's data" do
    other_account = create(:account)
    other_person  = other_account.owner
    expect do # wrong person:
      op.({ id: aw_owner.id, person_id: other_person.id }, 'account' => account)
    end.to raise_error ActiveRecord::RecordNotFound

    expect do # wrong AwardWalletOwner:
      op.({ id: aw_owner.id, person_id: other_person.id }, 'account' => other_account)
    end.to raise_error ActiveRecord::RecordNotFound
  end
end
