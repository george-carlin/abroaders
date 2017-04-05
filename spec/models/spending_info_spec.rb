require 'rails_helper'

RSpec.describe SpendingInfo do
  example '#credit_score=' do
    info = described_class.new
    # raises an error if passed an invalid credit score
    expect { info.credit_score = 349 }.to raise_error(Dry::Types::ConstraintError)
    expect { info.credit_score = 851 }.to raise_error(Dry::Types::ConstraintError)

    expect { info.credit_score = 350 }.not_to raise_error
    expect { info.credit_score = 850 }.not_to raise_error
  end
end
