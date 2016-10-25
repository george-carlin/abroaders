require "rails_helper"

describe InterestRegionsSurvey do
  let(:account) { create(:account, onboarding_state: :regions_of_interest) }

  describe "#persist!" do
    before do
      @region_0 = create(:region)
      @region_1 = create(:region)
      @region_2 = create(:region)
      @form = described_class.new(
        account:    account,
        region_ids: [@region_0, @region_2].map(&:id),
      )
    end

    it "adds regions of interest to the account" do
      @form.save!
      expect(account.regions_of_interest).to match_array [@region_0, @region_2]
    end

    it "updates the account's onboarding state" do
      @form.save!
      account.reload
      expect(account.onboarding_state).to eq "account_type"
    end
  end
end
