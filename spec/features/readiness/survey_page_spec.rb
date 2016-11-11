require "rails_helper"

describe "readiness survey page", :onboarding, :js do
  shared_examples "form for one person" do |type|
    case type
    when :owner
      let(:person) { owner }
      let(:other_person) { companion }
      other_type = :companion
    when :companion
      let(:person) { companion }
      let(:other_person) { owner }
      other_type = :owner
    else
      raise "invalid type"
    end

    example "radios" do
      expect(page).to have_field "readiness_survey_who_#{type}", checked: true
      expect(page).to have_field :readiness_survey_who_neither
      expect(page).to have_no_field :readiness_survey_who_both
      expect(page).to have_no_field "readiness_survey_who_#{other_type}"
    end

    example 'hiding/showing unreadiness reason' do
      field_to_show     = "readiness_survey_#{type}_unreadiness_reason"
      field_not_to_show = "readiness_survey_#{other_type}_unreadiness_reason"
      expect(page).to have_no_field field_to_show
      expect(page).to have_no_field field_not_to_show
      choose :readiness_survey_who_neither
      expect(page).to have_field field_to_show
      expect(page).to have_no_field field_not_to_show
      choose "readiness_survey_who_#{type}"
      expect(page).to have_no_field field_to_show
      expect(page).to have_no_field field_not_to_show
    end

    example "submitting 'ready'" do
      choose "readiness_survey_who_#{type}"
      submit_form
      person.reload
      expect(person).to be_ready
      expect(person.unreadiness_reason).to be_nil
      if other_person
        other_person.reload
        expect(other_person).not_to be_ready
        expect(other_person.unreadiness_reason).to be_nil
      end
      expect(current_path).to eq new_phone_number_path
      expect(account.reload.onboarding_state).to eq 'phone_number'
    end

    example "submitting 'not ready'" do
      choose :readiness_survey_who_neither
      submit_form
      person.reload
      expect(person).not_to be_ready
      expect(person.unreadiness_reason).to be_nil
      if other_person
        other_person.reload
        expect(other_person).not_to be_ready
        expect(other_person.unreadiness_reason).to be_nil
      end
      expect(current_path).to eq new_phone_number_path
      expect(account.reload.onboarding_state).to eq 'phone_number'
    end

    example "submitting 'I'm not ready' with a reason" do
      choose :readiness_survey_who_neither
      # strips whitespace:
      fill_in "readiness_survey_#{type}_unreadiness_reason", with: '  something '
      submit_form
      person.reload
      expect(person).not_to be_ready
      expect(person.unreadiness_reason).to eq 'something'
      if other_person
        other_person.reload
        expect(other_person).not_to be_ready
        expect(other_person.unreadiness_reason).to be_nil
      end
      expect(current_path).to eq new_phone_number_path
      expect(account.reload.onboarding_state).to eq 'phone_number'
    end
  end

  let(:submit_form) { click_button "Save and continue" }

  let(:owner)     { account.owner }
  let(:companion) { account.companion }

  context 'for a solo account' do
    let(:account) { create(:account, :eligible, onboarding_state: :readiness) }
    before do
      login_as_account(account)
      visit survey_readiness_path
    end

    include_examples 'form for one person', :owner

    example "labels" do
      expect(page).to have_content "Yes - I'm ready now"
      expect(page).to have_content "No - I'm not ready yet"
    end
  end

  context 'for a couples account' do
    let(:account) { create(:couples_account, onboarding_state: :readiness) }

    before do
      owner.update!(eligible: owner_eligible)
      companion.update!(eligible: companion_eligible)
      login_as_account(account)
      visit survey_readiness_path
    end

    let(:owner_eligible) { false }
    let(:companion_eligible) { false }

    context 'when only owner is eligible' do
      let(:owner_eligible) { true }

      include_examples 'form for one person', :owner

      example "labels" do
        expect(page).to have_content "Yes - I'm ready now"
        expect(page).to have_content "No - I'm not ready yet"
      end
    end

    context 'when only companion is eligible' do
      let(:companion_eligible) { true }

      include_examples 'form for one person', :companion

      example "labels" do
        expect(page).to have_content "Yes - I'm ready"
        expect(page).to have_content "No - I'm not ready"
      end
    end

    context 'when both people are eligible' do
      let(:companion_eligible) { true }
      let(:owner_eligible) { true }

      example 'radios' do
        expect(page).to have_field :readiness_survey_who_both, checked: true
        expect(page).to have_field :readiness_survey_who_owner
        expect(page).to have_field :readiness_survey_who_neither
        expect(page).to have_field :readiness_survey_who_companion
      end

      example 'hiding/showing unreadiness reason' do
        expect(page).to have_no_field :readiness_survey_owner_unreadiness_reason
        expect(page).to have_no_field :readiness_survey_companion_unreadiness_reason
        choose :readiness_survey_who_owner
        expect(page).to have_no_field :readiness_survey_owner_unreadiness_reason
        expect(page).to have_field :readiness_survey_companion_unreadiness_reason
        choose :readiness_survey_who_neither
        expect(page).to have_field :readiness_survey_owner_unreadiness_reason
        expect(page).to have_field :readiness_survey_companion_unreadiness_reason
        choose :readiness_survey_who_companion
        expect(page).to have_field :readiness_survey_owner_unreadiness_reason
        expect(page).to have_no_field :readiness_survey_companion_unreadiness_reason
        choose :readiness_survey_who_both
        expect(page).to have_no_field :readiness_survey_owner_unreadiness_reason
        expect(page).to have_no_field :readiness_survey_companion_unreadiness_reason
      end

      example "labels" do
        owner_name = owner.first_name
        comp_name  = companion.first_name
        expect(page).to have_content "Both #{owner_name} and #{comp_name} are ready now"
        expect(page).to have_content "#{owner_name} is ready now but #{comp_name} isn't"
        expect(page).to have_content "#{comp_name} is ready now but #{owner_name} isn't"
        expect(page).to have_content "Neither of us is ready yet"
      end

      example "submitting 'both are ready'" do
        choose :readiness_survey_who_both
        submit_form
        owner.reload
        companion.reload
        expect(companion).to be_ready
        expect(owner).to be_ready
        expect(companion.unreadiness_reason).to be_nil
        expect(owner.unreadiness_reason).to be_nil
        expect(current_path).to eq new_phone_number_path
        expect(account.reload.onboarding_state).to eq 'phone_number'
      end

      example "submitting 'owner is ready'" do
        choose :readiness_survey_who_owner
        fill_in :readiness_survey_companion_unreadiness_reason, with: ' whatever '
        submit_form
        owner.reload
        companion.reload
        expect(owner).to be_ready
        expect(companion).not_to be_ready
        expect(owner.unreadiness_reason).to be_nil
        expect(companion.unreadiness_reason).to eq 'whatever'
        expect(current_path).to eq new_phone_number_path
        expect(account.reload.onboarding_state).to eq 'phone_number'
      end

      # (haven't written tests for all the different permutations of submitting
      # unreadiness reasons)

      example "submitting 'companion is ready'" do
        choose :readiness_survey_who_companion
        submit_form
        expect(companion.reload).to be_ready
        expect(owner.reload).not_to be_ready
        expect(current_path).to eq new_phone_number_path
        expect(account.reload.onboarding_state).to eq 'phone_number'
      end

      example "submitting 'neither is ready'" do
        choose :readiness_survey_who_neither
        submit_form
        expect(owner.reload).not_to be_ready
        expect(companion.reload).not_to be_ready
        expect(current_path).to eq new_phone_number_path
        expect(account.reload.onboarding_state).to eq 'phone_number'
      end
    end
  end
end
