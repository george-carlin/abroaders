module AdminArea
  class RecommendationsMailer < ApplicationMailer
    def recommendations_ready(opts = {})
      opts.symbolize_keys!
      @account = Account.find(opts.fetch(:account_id))
      mail(to: @account.email, subject: "Action Needed: Card Recommendations Ready")
    end
  end
end
