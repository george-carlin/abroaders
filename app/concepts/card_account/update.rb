class CardAccount < CardAccount.superclass
  class Update < Trailblazer::Operation
    step Nested(Edit)
    step Contract::Validate(key: :card)
    step Contract::Persist()
    success :enqueue_zapier_webhook!

    private

    def enqueue_zapier_webhook!(_opts, model:, **)
      ZapierWebhooks::CardAccount::Updated.enqueue(model)
    end
  end
end
