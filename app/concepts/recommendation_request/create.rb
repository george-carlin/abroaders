class RecommendationRequest < RecommendationRequest.superclass
  class Create < Trailblazer::Operation
    success :validate_person_type!
    success :setup_people!
    step :people_can_create?
    success :create_requests!

    private

    def validate_person_type!(account:, params:, **)
      type = params.fetch(:person_type)
      unless %w[owner companion both].include?(type)
        raise "invalid type '#{params[:person_type]}'"
      end

      if type == 'companion' && !account.couples?
        raise "person type can't be \"companion\" for a solo account"
      end
    end

    def setup_people!(opts, account:, params:, **)
      type = params.fetch(:person_type)
      opts['people'] = case type
                       when 'both'
                         account.people.to_a
                       when 'owner'
                         [account.owner]
                       when 'companion'
                         [account.companion]
                       end
    end

    def people_can_create?(people:, **)
      people.all? { |person| Policy.new(person).create? }
    end

    def create_requests!(people:, **)
      ApplicationRecord.transaction do
        people.each { |person| RecommendationRequest.unconfirmed.create!(person: person) }
      end
    end
  end
end
