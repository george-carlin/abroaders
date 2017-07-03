module ZapierWebhooksMacros
  def be_queued_with_id(id)
    receive(:perform_later).with(id: id)
  end

  def expect_to_queue_card_opened_webhook_with_id(id)
    expect(ZapierWebhooks::Cards::Opened).to be_queued_with_id(id)
  end

  def expect_not_to_queue_card_opened_webhook
    expect(ZapierWebhooks::Cards::Opened).not_to receive(:perform_later)
  end
end
