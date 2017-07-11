require 'rails_helper'

RSpec.describe Registration::Update do
  let(:op) { described_class }
  let(:account) { create_account }
  let(:current_pw) { 'abroaders123' } # see sample_data_macros.rb

  let(:params) { { account: {} } }

  def get_errors(result)
    result['contract.default'].errors
  end

  describe 'updating email address' do
    example '' do
      params[:account][:email] = email = 'mynewemail@example.com'
      result = op.(params, 'current_account' => account)
      expect(result.success?).to be true
      expect(account.reload.email).to eq email
    end

    example 'strips whitespace and saves as downcase' do
      params[:account][:email] = email = '   MYNeweMAIL@exampLE.com   '
      result = op.(params, 'current_account' => account)
      expect(result.success?).to be true
      expect(account.reload.email).to eq email.strip.downcase
    end

    example 'failure - not a valid email address' do
      params[:account][:email] = 'not valid at example dot com'
      expect do
        result = op.(params, 'current_account' => account)
        expect(result.success?).to be false
        expect(get_errors(result)[:email]).to include 'is invalid'
        account.reload
      end.not_to change { account.email }
    end

    example 'invalid - email already taken by other account' do
      email = 'taken@example.com'
      create_account(email: email)
      params[:account][:email] = email
      expect do
        result = op.(params, 'current_account' => account)
        expect(result.success?).to be false
        expect(get_errors(result)[:email]).to include 'has already been taken'
        account.reload
      end.not_to change { account.email }
    end

    example 'invalid - email already taken by admin' do
      email = 'taken@example.com'
      create_admin(email: email)
      params[:account][:email] = email
      expect do
        result = op.(params, 'current_account' => account)
        expect(result.success?).to be false
        expect(get_errors(result)[:email]).to include 'has already been taken'
        account.reload
      end.not_to change { account.email }
    end
  end

  describe 'updating password' do
    before do
      params[:account] = {
        current_password: 'abroaders123',
        password: 'my_new_password',
        password_confirmation: 'my_new_password',
      }
    end

    example '' do
      expect(account.valid_password?('my_new_password')).to be false
      result = op.(params, 'current_account' => account)
      expect(result.success?).to be true
      account.reload
      expect(account.valid_password?('my_new_password')).to be true
    end

    example 'invalid - current password incorrect' do
      params[:account][:current_password] = 'bzzzzt - wrong!'
      expect do
        result = op.(params, 'current_account' => account)
        expect(result.success?).to be false
        expect(get_errors(result)[:current_password]).to eq ['is invalid']
        account.reload
      end.not_to change { account.encrypted_password }
    end

    example 'invalid - password too short' do
      pw = 'a' * (Registration::EditForm::PASSWORD_LENGTH.min - 1)
      params[:account][:password] = params[:account][:password_confirmation] = pw
      expect do
        result = op.(params, 'current_account' => account)
        expect(result.success?).to be false
        expect(get_errors(result)[:password][0]).to match(/is too short/)
        account.reload
      end.not_to change { account.encrypted_password }
    end

    example 'invalid - password too long' do
      pw = 'a' * (Registration::EditForm::PASSWORD_LENGTH.max + 1)
      params[:account][:password] = params[:account][:password_confirmation] = pw
      expect do
        result = op.(params, 'current_account' => account)
        expect(result.success?).to be false
        expect(get_errors(result)[:password][0]).to match(/is too long/)
        account.reload
      end.not_to change { account.encrypted_password }
    end

    example 'invalid - passwords dont match' do
      params[:account][:current_password] = 'pass_my_new_word'
      expect do
        result = op.(params, 'current_account' => account)
        expect(result.success?).to be false
        account.reload
      end.not_to change { account.encrypted_password }
    end
  end
end
