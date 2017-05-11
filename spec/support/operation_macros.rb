module OperationMacros
  # Runs a trailblazer op and raises an exception if it fails. Use when you
  # know that your test data is good and that a failed op means that you wrote
  # the test wrong (or the op is broken.)
  def run!(op, *args)
    result = op.(*args)
    if result.failure?
      message =  "op #{op} was expected to succeed, but it failed.\n\n  Args: #{args.join(', ')}"

      message << "\n\n result['error']: #{result['error']}" if result['error']

      # FIXME this only works if the contract uses ActiveModel validations as
      # opposed to dry-validation
      if (contract = result['contract.default'])
        if contract.errors.any?
          message << "\n\n contract.default errors: #{contract.errors}"
        end
      end

      raise message
    end
    result
  end
end
