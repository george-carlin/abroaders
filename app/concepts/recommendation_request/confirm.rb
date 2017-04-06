class RecommendationRequest < RecommendationRequest.superclass
  class Confirm < Trailblazer::Operation
    step :find_unconfirmed_requests
    success :confirm_requests!

    private

    def find_unconfirmed_requests(opts, account:, **)
      requests = account.unconfirmed_recommendation_requests
      return false unless requests.any?
      opts['model'] = requests
    end

    def confirm_requests!(model:, **)
      ApplicationRecord.transaction { model.each(&:confirm!) }
    end
  end
end
