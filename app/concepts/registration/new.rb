module Registration
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
end
