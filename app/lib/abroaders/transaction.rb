module Abroaders
  # Sample usage:
  #
  #   class MyOp < Trailblazer::Operation
  #     step Wrap(Abroaders::Transaction) {
  #       step :foo
  #       step :bar
  #     }
  #
  #     # note that if you want to use do/end it must be wrapped in brackets:
  #     step (Wrap(Abroaders::Transaction) do
  #       step :foo
  #       step :bar
  #     end)
  #   end
  #
  # Remember that the 'Wrap' step returns the value of the proc that's passed
  # to it, rather than the block. So if the inner steps fail,
  # ApplicationRecord.transaction will still return a truthy value and so the
  # 'Wrap' step will pass. This appears to be a deliberate design decision on
  # the part of Trailblazer:
  # http://trailblazer.to/gems/operation/2.0/api.html#wrap
  #
  # So the following operation will always succeed:
  #
  #   class MyOp < Trailblazer::Operation
  #     step Wrap(Abroaders::Transaction) {
  #       step :fail
  #     }
  #
  #     def fail
  #       false
  #     end
  #   end
  #
  # The workaround is to add a nested `failure` step that raises
  # ActiveRecord::Rollback:
  #
  #   class MyOp < Trailblazer::Operation
  #     step Wrap(Abroaders::Transaction) {
  #       step :fail
  #       failure :rollback
  #     }
  #
  #     def fail
  #       false
  #     end
  #
  #     def rollback
  #       raise ActiveRecord::Rollback
  #     end
  #   end
  #
  # Not sure if this is the 'correct' way to do this, but it works.
  module Transaction
    extend Uber::Callable

    def self.call(*, &block)
      ApplicationRecord.transaction(&block)
    end
  end
end
