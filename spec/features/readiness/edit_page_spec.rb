require 'rails_helper'

RSpec.describe 'edit readiness page' do
  let(:account)   { create((couples ? :couples_account : :account), :onboarded) }
  let(:owner)     { account.owner }
  let(:companion) { account.companion }

  before do
    owner.update!(ready: own_r, eligible: own_e)
    companion.update!(ready: com_r, eligible: com_e) if couples
    login_as(account)
    visit edit_readiness_path
  end

  def click_ready_button(person)
    click_button "#{person.first_name} is now ready"
  end

  let(:own_r) { false }
  let(:com_r) { false }

  let(:submit_form) { click_button 'Submit' }

  # cases where the page is inaccessible (no-one eligible or everyone ready)
  # are handled by the controller spec

  context 'for solo account when unready' do
    let(:couples) { false }
    let(:own_e)   { true }
    let(:own_r)   { false }

    example 'updating to ready' do
      expect(owner).to be_unready
      click_ready_button(owner)
      expect(owner.reload).to be_ready
      # TODO what page does it then redirect to?
    end
  end

  context 'for couples account' do
    let(:couples) { true }
    let(:own_e)   { true }
    let(:com_e)   { true }

    context 'with both people eligible' do
      context 'and unready' do
        let(:own_r) { false }
        let(:com_r) { false }

        example 'updating both to ready' do
          select('Both of us are now ready', from: 'readiness[who]')
          submit_form
          expect(owner.reload).to be_ready
          expect(companion.reload).to be_ready
        end

        example 'updating owner to ready' do
          select(
            "#{owner.first_name} is now ready - #{companion.first_name} still needs more time",
            from: 'readiness[who]',
          )
          submit_form
          expect(owner.reload).to be_ready
          expect(companion.reload).to be_unready
        end

        example 'updating companion to ready' do
          select(
            "#{companion.first_name} is now ready - #{owner.first_name} still needs more time",
            from: 'readiness[who]',
          )
          submit_form
          expect(owner.reload).to be_unready
          expect(companion.reload).to be_ready
        end
      end

      context 'and only owner is unready' do
        let(:own_r) { false }
        let(:com_r) { true }

        example 'updating to ready' do
          click_ready_button(owner)
          expect(owner.reload).to be_ready
          expect(companion.reload).to be_ready # was already ready
        end
      end

      context 'and only companion is unready' do
        let(:own_r) { true }
        let(:com_r) { false }

        example 'updating to ready' do
          click_ready_button(companion)
          expect(companion.reload).to be_ready
          expect(owner.reload).to be_ready # was already ready
        end
      end
    end

    context 'when only owner is eligible' do
      let(:com_e) { false }
      let(:own_r) { false }

      example 'updating to ready' do
        click_ready_button(owner)
        expect(owner.reload).to be_ready
        expect(companion.reload).to be_unready
      end
    end

    context 'when only companion is eligible' do
      let(:own_e) { false }
      let(:com_r) { false }

      example 'updating to ready' do
        click_ready_button(companion)
        expect(owner.reload).to be_unready
        expect(companion.reload).to be_ready
      end
    end
  end
end
