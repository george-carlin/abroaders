require "rails_helper"

describe "edit readiness page", :js do
  context "when account has companion" do
    let(:account) { create(:account, :with_companion, :onboarded_cards, :onboarded_balances) }
    let(:owner) { account.owner }
    let(:companion) { account.companion }

    before do
      owner.update_attributes!(eligible: true, ready: false)
      login_as(account)
      visit edit_readiness_path
    end

    context "when both are unready" do
      context "update both" do
        let(:click_both_ready_btn) { click_button "Both are ready" }

        example "updating companion and owner status to 'ready'" do
          click_both_ready_btn
          expect(owner.reload).to be_ready
          expect(companion.reload).to be_ready
        end

        example "tracking an Intercom event for owner and companion", :intercom do
          expect{click_both_ready_btn}.to \
          track_intercom_events("obs_ready_own", "obs_ready_com").for_email(account.email)
        end
      end

      context "update only owner" do
        let(:click_only_owner_ready_btn) { click_button "Only #{owner.first_name} is ready" }

        example "updating owner status to 'ready'" do
          click_only_owner_ready_btn
          expect(owner.reload).to be_ready
        end

        example "tracking an Intercom event for owner", :intercom do
          expect{click_only_owner_ready_btn}.to \
          track_intercom_event("obs_ready_own").for_email(account.email)
        end
      end

      context "update only companion" do
        let(:click_only_companion_ready_btn) { click_button "Only #{companion.first_name} is ready" }

        example "updating companion status to 'ready'" do
          click_only_companion_ready_btn
          expect(companion.reload).to be_ready
        end

        example "tracking an Intercom event for companion", :intercom do
          expect{click_only_companion_ready_btn}.to \
          track_intercom_event("obs_ready_com").for_email(account.email)
        end
      end
    end

    context "when only owner is ready" do
      let(:click_companion_ready_btn) { click_button "#{companion.first_name} is ready" }

      example "updating companion status to 'ready'" do
        click_companion_ready_btn
        expect(companion.reload).to be_ready
      end

      example "tracking an Intercom event for companion", :intercom do
        expect{click_companion_ready_btn}.to \
      track_intercom_event("obs_ready_com").for_email(account.email)
      end
    end

    context "when only companion is ready" do
      let(:click_owner_ready_btn) { click_button "#{owner.first_name} is ready" }

      example "updating companion status to 'ready'" do
        click_owner_ready_btn
        expect(owner.reload).to be_ready
      end

      example "tracking an Intercom event for owner", :intercom do
        expect{click_owner_ready_btn}.to \
      track_intercom_event("obs_ready_own").for_email(account.email)
      end
    end
  end

  context "when account hasn't companion" do
    let(:click_ready_btn) { click_button "I am now ready" }
    let(:account) { create(:account, :onboarded_cards, :onboarded_balances) }
    let(:owner) { account.owner }

    before do
      owner.update_attributes!(eligible: true, ready: false)
      login_as(account)
      visit edit_readiness_path
    end

    example "updating my status to 'ready'" do
      click_ready_btn
      expect(owner.reload).to be_ready
    end

    example "tracking an Intercom event", :intercom do
      expect{click_ready_btn}.to \
      track_intercom_event("obs_ready_own").for_email(account.email)
    end
  end
end
