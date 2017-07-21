class Admin::Edit < Trailblazer::Operation
  extend Contract::DSL
  contract Admin::EditRegistrationForm
  step :setup_model
  step Contract::Build()

  private

  def setup_model(opts, current_admin:, **)
    opts['model'] = current_admin
  end
end
