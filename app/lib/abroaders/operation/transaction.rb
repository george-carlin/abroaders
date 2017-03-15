module Abroaders
  module Operation
    # sample usage:
    #
    #   class MyOp < Trailblazer::Operation
    #     extend Abroaders::Operation::Transaction
    #
    #     step wrap_in_transaction {
    #       step :foo
    #       step :bar
    #     }
    #
    #     # note that if you want to use do/end it must be wrapped in brackets:
    #     step (wrap_in_transaction do
    #       step :foo
    #       step :bar
    #     end)
    #   end
    #
    module Transaction
      def wrap_in_transaction(&steps)
        Wrap(->(*, &block) { ApplicationRecord.transaction(&block) }, &steps)
      end
    end
  end
end
