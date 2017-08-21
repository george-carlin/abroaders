require 'rails_helper'

RSpec.describe 'password recovery pages', :auth do
  let(:email) { 'test@example.com' }
  let!(:account) { create_account(email: email) }

  describe 'requesting a password reset' do
    before { visit new_account_password_path }

    example 'requesting a password reset email' do
      fill_in :account_email, with: email

      expect do
        click_button 'Send me reset password instructions'
      end.to change { ApplicationMailer.deliveries.length }.by(1)
      message = ApplicationMailer.deliveries.last
      expect(message.to).to include email
      expect(message.subject).to eq 'Reset password instructions'

      # This doesn't work because Devise just sends the email inline, and
      # doesn't use a BG job. But it should! FIXME
      # expect do
      #   click_button 'Send me reset password instructions'
      # end.to send_email.to(email).with_subject("???")

      # show the sign in page, with an alert:
      expect(current_path).to eq new_account_session_path
      expect(page).to have_info_message 'You will receive an email'
    end

    example 'requesting a password reset for a non-existent email' do
      fill_in :account_email, with: 'yerwhat@ioawjeroa.com'
      expect do
        click_button 'Send me reset password instructions'
      end.not_to send_email
      expect(page).to have_error_message
    end

    example 'requesting a password reset with a blank email' do
      fill_in :account_email, with: ''
      expect do
        click_button 'Send me reset password instructions'
      end.not_to send_email
      expect(page).to have_error_message
    end
  end

  describe 'resetting with token' do
    before do
      # This is how Devise does it internally. I can't just call
      # Account.send_reset_password_instructions(...) because I won't know the
      # token that goes in the URL (it's not the same as the
      # reset_password_token attribute of the account.)
      raw, enc = Devise.token_generator.generate(Account, :reset_password_token)
      account.update!(reset_password_token: enc)

      visit edit_account_password_path(reset_password_token: raw)
    end

    # just a quick smoke test to make sure the page actually loads okay (which
    # it wasn't when I wrote this test, as I found out the hard way from a
    # user). CBA to write a full spec now.
    it 'looks okay' do
      expect(page).to have_content 'CHANGE YOUR PASSWORD'
    end
  end
end
