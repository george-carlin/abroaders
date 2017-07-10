class Registration::Edit < Trailblazer::Operation
  extend Contract::DSL
  contract Registration::EditForm
  step :setup_model
  step :setup_form

  private

  # This op and the Update op don't actually use the 'model' key, but set it so
  # that the controller will get access to the @model ivar:
  def setup_model(opts, current_account:, **)
    opts['model'] = current_account
  end

  def setup_form(opts, current_account:, **)
    opts['contract.default'] = opts['contract.default.class'].new(current_account)
  end
end
