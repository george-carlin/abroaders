module Registration
  module Operation
    class New < Trailblazer::Operation
      extend Contract::DSL

      contract SignUpForm

      step :setup_model!
      step Contract::Build()

      private

      def setup_model!(opts)
        opts['model'] = Account.new.tap(&:build_owner)
      end
    end

    class Create < Trailblazer::Operation
      step Nested(New)
      step Contract::Validate(key: :account)
      step :persist_model!

      private

      def persist_model!(opts, **)
        contract = opts['contract.default']
        contract.sync
        contract.model.test = TEST_EMAILS.any? { |r| r =~ contract.email.downcase }
        contract.model.save
      end

      # if the email address matches any of these regexes, set the 'test'
      # boolean flag on the account to TRUE, so that we can filter out these
      # fake accounts from our analytics:
      TEST_EMAILS = [
        /@abroaders.com/i,
        /@example.com/i,
        /\+test/i,
        /georgejulianmillo/i,
      ].freeze
    end
  end
end
