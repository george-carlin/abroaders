require "rails_helper"

describe "edit readiness page" do
  shared_examples "blocking visit edit readiness page" do
    it "takes me to the root path" do
      expect(current_path).to eq root_path
    end
  end

  def visit_edit_readiness_path(account)
    login_as(account)
    visit edit_readiness_path
  end

  def click_ready_button(person)
    click_button "#{person.first_name} is now ready"
  end

  let(:submit_form) { click_button "Submit" }

  context "when account has companion" do
    let(:account) { create(:account, :with_companion, :onboarded) }
    let(:owner) { account.owner }
    let(:companion) { account.companion }

    context "and only owner is unready" do
      before do
        owner.update_attributes!(ready: false)
        companion.update_attributes!(ready: true)
      end

      context "and owner is eligible" do
        before do
          owner.update_attributes!(eligible: true)
          visit_edit_readiness_path(account)
        end

        example "updating owner status to 'ready'" do
          click_ready_button(owner)
          expect(owner.reload).to be_ready
        end

        example "tracking an Intercom event for owner", :intercom do
          expect { click_ready_button(owner) }.to \
            track_intercom_events("obs_ready_own").for_email(account.email)
        end
      end

      context "and owner is uneligible" do
        before do
          owner.update_attributes!(eligible: false)
          visit_edit_readiness_path(account)
        end

        include_examples "blocking visit edit readiness page"
      end
    end

    context "and only companion is unready" do
      before do
        owner.update_attributes!(ready: true)
        companion.update_attributes!(ready: false)
      end

      context "and companion is eligible" do
        before do
          companion.update_attributes!(eligible: true)
          visit_edit_readiness_path(account)
        end

        example "updating companion status to 'ready'" do
          click_ready_button(companion)
          expect(companion.reload).to be_ready
        end

        example "tracking an Intercom event for companion", :intercom do
          expect { click_ready_button(companion) }.to \
            track_intercom_events("obs_ready_com").for_email(account.email)
        end
      end

      context "and companion is uneligible" do
        before do
          companion.update_attributes!(eligible: false)
          visit_edit_readiness_path(account)
        end

        include_examples "blocking visit edit readiness page"
      end
    end

    context "and both are unready" do
      before do
        owner.update_attributes!(ready: false)
        companion.update_attributes!(ready: false)
      end

      context "and both are eligible" do
        before do
          owner.update_attributes!(eligible: true)
          companion.update_attributes!(eligible: true)
          visit_edit_readiness_path(account)
        end

        context "and update both" do
          before { select("Both of us are now ready", from: "readiness[who]") }

          example "updating companion and owner status to 'ready'" do
            submit_form
            expect(owner.reload).to be_ready
            expect(companion.reload).to be_ready
          end

          example "tracking an Intercom event for owner and companion", :intercom do
            expect { submit_form }.to \
              track_intercom_events("obs_ready_own", "obs_ready_com").for_email(account.email)
          end
        end

        context "and update only owner" do
          before { select("#{owner.first_name} is now ready - #{companion.first_name} steel needs more time", from: "readiness[who]") }

          example "updating owner status to 'ready'" do
            submit_form
            expect(owner.reload).to be_ready
          end

          example "tracking an Intercom event for owner", :intercom do
            expect { submit_form }.to \
              track_intercom_events("obs_ready_own").for_email(account.email)
          end
        end

        context "and update only companion" do
          before { select("#{companion.first_name} is now ready - #{owner.first_name} steel needs more time", from: "readiness[who]") }

          example "updating companion status to 'ready'" do
            submit_form
            expect(companion.reload).to be_ready
          end

          example "tracking an Intercom event for companion", :intercom do
            expect { submit_form }.to \
              track_intercom_events("obs_ready_com").for_email(account.email)
          end
        end
      end

      context "and both are uneligible" do
        before do
          owner.update_attributes!(eligible: false)
          companion.update_attributes!(eligible: false)
          visit_edit_readiness_path(account)
        end

        include_examples "blocking visit edit readiness page"
      end

      context "and only owner is eligible" do
        before do
          owner.update_attributes!(eligible: true)
          companion.update_attributes!(eligible: false)
          visit_edit_readiness_path(account)
        end

        example "updating owner status to 'ready'" do
          click_ready_button(owner)
          expect(owner.reload).to be_ready
        end

        example "tracking an Intercom event for owner", :intercom do
          expect { click_ready_button(owner) }.to \
            track_intercom_events("obs_ready_own").for_email(account.email)
        end
      end

      context "and only companion is eligible" do
        before do
          owner.update_attributes!(eligible: false)
          companion.update_attributes!(eligible: true)
          visit_edit_readiness_path(account)
        end

        example "updating companion status to 'ready'" do
          click_ready_button(companion)
          expect(companion.reload).to be_ready
        end

        example "tracking an Intercom event for companion", :intercom do
          expect { click_ready_button(companion) }.to \
            track_intercom_events("obs_ready_com").for_email(account.email)
        end
      end
    end

    context "and both are ready" do
      before do
        owner.update_attributes!(ready: true)
        companion.update_attributes!(ready: true)
        visit_edit_readiness_path(account)
      end

      include_examples "blocking visit edit readiness page"
    end
  end

  context "when account hasn't companion" do
    let(:account) { create(:account, :onboarded) }
    let(:owner) { account.owner }

    context "and owner is ready" do
      before { owner.update_attributes!(ready: true) }

      context "and owner is eligible" do
        before do
          owner.update_attributes!(eligible: true)
          visit_edit_readiness_path(account)
        end

        include_examples "blocking visit edit readiness page"
      end

      context "and owner is ineligible" do
        before do
          owner.update_attributes!(eligible: false)
          visit_edit_readiness_path(account)
        end

        include_examples "blocking visit edit readiness page"
      end
    end

    context "when owner is unready" do
      before { owner.update_attributes!(ready: false) }

      context "and owner is eligible" do
        before do
          owner.update_attributes!(eligible: true)
          visit_edit_readiness_path(account)
        end

        example "updating my status to 'ready'" do
          click_ready_button(owner)
          expect(owner.reload).to be_ready
        end

        example "tracking an Intercom event", :intercom do
          expect { click_ready_button(owner) }.to \
            track_intercom_event("obs_ready_own").for_email(account.email)
        end
      end

      context "and owner is ineligible" do
        before do
          owner.update_attributes!(eligible: false)
          visit_edit_readiness_path(account)
        end

        include_examples "blocking visit edit readiness page"
      end
    end
  end
end
