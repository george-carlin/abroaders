require 'rails_helper'

RSpec.describe Abroaders::Transaction do
  class MyOp < Trailblazer::Operation
    step Wrap(Abroaders::Transaction) {
      step :create_account_0
      step :raise_error
      step :create_account_1
      step :dont_pass
      failure :rollback
    }
    failure :log_transaction_failed

    private

    def create_account_0(params:, **)
      Account.create!(
        email: "account#{params[:i] * 2}@example.com",
        password: 'abroaders123',
        password_confirmation: 'abroaders123',
      )
    end

    def raise_error(params:, **)
      raise ActiveRecord::Rollback if params[:will_raise]
      true
    end

    def create_account_1(params:, **)
      Account.create!(
        email: "account#{(params[:i] * 2) + 1}@example.com",
        password: 'abroaders123',
        password_confirmation: 'abroaders123',
      )
    end

    def dont_pass(params:, **)
      !params[:will_fail]
    end

    def rollback(*)
      raise ActiveRecord::Rollback
    end

    def log_transaction_failed(opts)
      opts['error'] = 'transaction failed'
    end
  end

  let(:op) { MyOp }

  it 'wraps steps in a transaction' do
    expect do
      result = op.(i: 0)
      expect(result.success?).to be true
      expect(result['error']).to be nil
    end.to change { Account.count }.by(2)

    expect do
      result = op.(i: 1, will_raise: true)
      expect(result.success?).to be false
      expect(result['error']).to eq 'transaction failed'
    end.not_to change { Account.count }
  end

  it 'fails if you rollback' do
    result = op.(i: 0, will_fail: true)
    expect(result.success?).to be false
    expect(result['error']).to eq 'transaction failed'
  end
end
