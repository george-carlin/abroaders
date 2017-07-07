class CardAccount < CardAccount.superclass
  class Destroy < Trailblazer::Operation
    success :setup_model!
    success :destroy_card_account!

    private

    def destroy_card_account!(opts, **)
      opts['model'].destroy!
    end

    def setup_model!(opts, current_account:, params:, **)
      opts['model'] = current_account.card_accounts.find(params.fetch(:id))
    end
  end
end
